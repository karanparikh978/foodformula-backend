class RestaurantController < ApplicationController

    require 'csv'
    before_action :authenticate_user, except: [:get_menu_template,:generate_enquiry,:export_recipes,:get_all_enquiries,:update_enquiry,:remove_enquiry,:get_enquiry_by_id,:get_menu_template_v4,:get_menu_template_v3,:get_recipe_details_from_category,:menu_init]
    before_action :authenticate_admin, only: [:get_all_enquiries,:update_enquiry,:remove_enquiry,:get_enquiry_by_id]


    def create_category
        unless has_sufficient_params(['restaurant_id','name'])
            return
        end

        restaurant_category = RestaurantCategory.new
        restaurant_category.name = params[:name].strip.titleize
        restaurant_category.restaurant_id = params[:restaurant_id]
        restaurant_category.status_id = CONTENT_STATUS_PUBLISHED

        if restaurant_category.save
            render_result_json restaurant_category
        end

    end

    def remove_category
        unless has_sufficient_params(['id'])
            return
        end

        category = RestaurantCategory.where(id: params[:id]).first

        if category.present?
            foods = category.food_items
            foods.update_all(status_id: CONTENT_STATUS_DISCARDED)
            category.status_id = CONTENT_STATUS_DISCARDED
            category.save
            render_success_json 'Category Removed !'
        else
            render_500_json 'Category not present.'
            return
        end
    end

    def update_category
        unless has_sufficient_params(['id'])
            return
        end

        category = RestaurantCategory.where(id: params[:id]).first

        unless category
            render_500_json 'Category not present.'
            return
        end
        if category.present?
            category.name = params[:name].strip.titleize if params[:name].present?
            category.status_id = params[:status_id] if params[:status_id].present?
            category.save
            render_success_json 'Category Updated !'
        end
    end

    def add_or_update_category
        if params[:id].present?
            category = RestaurantCategory.where(id: params[:id]).first

            unless category
                render_500_json 'Category not present.'
                return
            end
            if category.present?
                category.name = params[:name].strip.titleize if params[:name].present?
                category.status_id = params[:status_id] if params[:status_id].present?
                category.save
                render_success_json 'Category Updated !'
            end
        else
            unless has_sufficient_params(['restaurant_id','name'])
                return
            end
            restaurant_category = RestaurantCategory.new
            restaurant_category.name = params[:name].strip.titleize
            restaurant_category.restaurant_id = params[:restaurant_id]
            restaurant_category.status_id = CONTENT_STATUS_PUBLISHED
    
            if restaurant_category.save
                render_result_json restaurant_category
            end
        end
    end

    def get_all_categories
        categories = @user.categories.where('restaurant_categories.status_id = ?',CONTENT_STATUS_PUBLISHED).order('created_at desc')
        map = []

        categories.each do |cat|
            map << {id: cat.id, name: cat.name, cat_id: [cat.id.to_s]}
        end

        render_result_json map
    end

    def create_food_item
        unless has_sufficient_params(['restaurant_id','category_id','name'])
            return
        end
        masters_food_item = MastersFoodItem.new
        masters_food_item.name = params[:name].strip.titleize
        masters_food_item.category_id = params[:category_id]
        masters_food_item.restaurant_id = params[:restaurant_id]
        masters_food_item.status_id = CONTENT_STATUS_DRAFT
        if masters_food_item.save
            render_result_json masters_food_item
        end
    end

    def create_food_item_in_bulk
        unless has_sufficient_params(['restaurant_id','category_id','recipe_names'])
            return
        end
        recipe_names = params[:recipe_names]
        created_food_items = []
        recipe_names.each do |recipe_name|
            masters_food_item = MastersFoodItem.new
            masters_food_item.name = recipe_name.strip.titleize
            masters_food_item.category_id = params[:category_id]
            masters_food_item.restaurant_id = params[:restaurant_id]
            masters_food_item.status_id = CONTENT_STATUS_DRAFT
            if masters_food_item.save
                obj = {}
                obj['id'] = masters_food_item.id
                obj['name'] = masters_food_item.name
                obj['status_id'] = masters_food_item.status_id
                created_food_items << obj
            end
        end
        render_result_json created_food_items
    end

    def get_food_item_details_by_id
        unless has_sufficient_params(['id','restaurant_id'])
            return
        end
        masters_food_item = MastersFoodItem.find params[:id]
        unless masters_food_item
            render_500_json 'Food Item Not Present.'
            return
        end
        masters_food_item = masters_food_item.as_json
        user = User.includes([entities: :master],[languages: :master]).where(id: params[:restaurant_id]).first
        food_items_price_arr = []
        food_items_alias_arr = []
        if user.entities.present?
            user_entities = user.entities
            user_entities.each do |entity|
                food_item_price = FoodItemPrice.where(food_item_id: masters_food_item['id'],entity_id: entity.master.id).first
                obj = {}
                obj['id'] = nil
                obj['entity_name'] = entity.master.name rescue nil
                obj['entity_id'] = entity.master.id rescue nil
                obj['price'] = nil
                if food_item_price.present?
                    obj['id'] = food_item_price.id
                    obj['price'] = food_item_price.price
                end
                food_items_price_arr << obj
            end
        end
        if user.languages.present?
            user_languages = user.languages
            user_languages.each do |language|
                food_item_alias = FoodItemAlias.where(food_item_id: masters_food_item['id'],language_id: language.master.id).first
                obj = {}
                obj['id'] = nil
                obj['language_name'] = language.master.name rescue nil
                obj['language_id'] = language.master.id rescue nil
                obj['alias'] = nil
                if food_item_alias.present?
                    obj['id'] = food_item_alias.id
                    obj['alias'] = food_item_alias.alias
                end
                food_items_alias_arr << obj
            end
        end

        categories = User.where(id: params[:restaurant_id]).first.categories.where('restaurant_categories.status_id != ?',CONTENT_STATUS_DISCARDED).select(:id,:name)
        masters_food_item['categories'] = categories
        images = EntityImage.where(entity_type: ENTITY_TYPE_FOOD_ITEM,entity_type_id: params[:id],status_id: CONTENT_STATUS_PUBLISHED).select(:id,:url).as_json
        masters_food_item['recipe_images'] = images
        masters_food_item['food_item_prices'] = food_items_price_arr
        masters_food_item['food_item_aliases'] = food_items_alias_arr
        render_result_json masters_food_item
    end

    def update_food_item
        unless has_sufficient_params(['id'])
            return
        end
        masters_food_item = MastersFoodItem.find params[:id]
        unless masters_food_item
            render_500_json 'Food Item not present.'
        end

        masters_food_item.name = params[:name].strip.titleize if params[:name].present?
        masters_food_item.status_id = params[:status_id] if params[:status_id].present?
        masters_food_item.category_id = params[:category_id] if params[:category_id].present?
        masters_food_item.ingredients_info = params[:ingredients_info]
        masters_food_item.recipe_type = params[:recipe_type] if params[:recipe_type].present?
        masters_food_item.total_cooked_weight = params[:total_cooked_weight]
        masters_food_item.serving_description = params[:serving_description]
        masters_food_item.per_serving_weight = params[:per_serving_weight]
        masters_food_item.per_serving_cost_price = params[:per_serving_cost_price]
        masters_food_item.per_serving_selling_price = params[:per_serving_selling_price]
        masters_food_item.cooking_info = params[:cooking_info]
        masters_food_item.allergies_info = params[:allergies_info]
        masters_food_item.expiry_date = params[:expiry_date]
        masters_food_item.used_as_ingredient = params[:used_as_ingredient]
        masters_food_item.allergy_ids = params[:allergy_ids]
        masters_food_item.meal_type_ids = params[:meal_type_ids]
        masters_food_item.meal_types_info = params[:meal_types_info]
        masters_food_item.is_liquid = params[:is_liquid]
        masters_food_item.is_jain = params[:is_jain]
        if masters_food_item.save
            render_success_json "Details updated"
        end
    end

    def remove_food_item
        unless has_sufficient_params(['id'])
            return
        end
        masters_food_item = MastersFoodItem.find params[:id]
        unless masters_food_item
            render_500_json 'Food Item Not Present.'
            return
        end
        masters_food_item.status_id = CONTENT_STATUS_DISCARDED
        if masters_food_item.save
            render_success_json 'Food Item Removed !'
        end
    end

    def get_recipes_by_category
        unless has_sufficient_params(['id'])
            return
        end

        category = RestaurantCategory.find params[:id]
        unless category
            render_500_json 'Category not present.'
        end
        recipes = category.food_items.where('masters_food_items.status_id != ?',CONTENT_STATUS_DISCARDED).order(:sort_by)
        if recipes.present?
            map = []
            recipes.each do |recipe|
                map << {id: recipe.id, name: recipe.name, price: recipe.per_serving_selling_price, status_id: recipe.status_id, recipe_type: recipe.recipe_type, cat_id: recipe.category.id.to_s }
            end
            render_result_json map
        else
            render_success_json 'Recipes not available.'
        end

    end

    def search_recipe
        q = params[:name].downcase
        recipes = MastersFoodItem.joins(:category).where("masters_food_items.name ilike ? AND masters_food_items.status_id != ? AND masters_food_items.restaurant_id = ? AND restaurant_categories.status_id = ?","%#{q}%", CONTENT_STATUS_DISCARDED, params[:restaurant_id], CONTENT_STATUS_PUBLISHED)

        categories_arr = {}
        recipes_arr = {}
        recipes.each do |r|
            recipes_arr[r.category_id] = []
        end

        recipes.each do |r|
            cooked_weight = r.composition_quantity.to_f rescue 0
            serving_weight = r.restaurant_serving_weight.to_f rescue 0

            recipes_details = recipes.select(:id,:name,:per_serving_selling_price,:status_id,:recipe_type)
            recipes_arr[r.category_id] << {id: r.id, name: r.name.titlecase, recipe_type: r.recipe_type, per_serving_selling_price: r.per_serving_selling_price, status_id: r.status_id}
            
            categories_arr[r.category_id] = {id: r.category_id, name: r.category.name, recipes: recipes_arr[r.category_id]}
        end
        
        render_result_json categories_arr
    end

    def get_qr_code_category
        unless has_sufficient_params(['restaurant_id'])
            return
        end
        user = User.where(id: params[:restaurant_id]).first
        if user.present?
            render_result_json user.qr_code_category
        else
            render_500_json 'User is not present.'
        end
    end

    def update_qr_code_category
        unless has_sufficient_params(['restaurant_id'])
            return
        end
        user = User.where(id: params[:restaurant_id]).first
        if user.present?
            user.qr_code_category = params[:qr_code_category]
            user.save
            render_success_json 'QR Code Category Updated.'
        else
            render_500_json 'User is not present.'
        end
    end

    def get_menu_template
        unless has_sufficient_params(['id'])
            return
        end

        @user = User.where(id: params[:id]).first

        @lang = params['lang'].present? ? params['lang'] : 'eng'

        @eggitarian = 'https://firebasestorage.googleapis.com/v0/b/foodformula-f69fa.appspot.com/o/eggitarian-icon.svg?alt=media&token=a09a4912-e93e-4c7d-bd68-206df3152b37'
        @nonveg = 'https://firebasestorage.googleapis.com/v0/b/foodformula-f69fa.appspot.com/o/nonveg.svg?alt=media&token=69fae8e3-66dd-44dc-bab6-f0185f90f111'
        @veg = 'https://firebasestorage.googleapis.com/v0/b/foodformula-f69fa.appspot.com/o/veg%20(1).svg?alt=media&token=aefa5234-6805-4f21-bc03-b16aaf11d753'

        categories_id = @user.present? && @user.qr_code_category.present? ? @user.qr_code_category.split("@") : []

        categories = RestaurantCategory.includes(:food_items).where(id: categories_id).where(restaurant_id: @user.id).where(status_id: CONTENT_STATUS_PUBLISHED)

        @logo_image = EntityImage.where(entity_type_id: params[:id], entity_type: ENTITY_TYPE_LOGO, status_id: CONTENT_STATUS_PUBLISHED).first

        meal_types = MEAL_TYPES

        allergies = ALLERGIES

        @category = []

        categories.each do |cat|
            recipes = []
            cat.food_items.order(:sort_by).each do |fi|
                if fi.status_id == CONTENT_STATUS_PUBLISHED
                    cooked_weight = fi.total_cooked_weight.to_f rescue 0
                    serving_weight = fi.per_serving_weight.to_f rescue 0

                    ingredients_info = fi.ingredients_info

                    price = fi.per_serving_selling_price
                    currency = @user.currency.present? ? @user.currency : '£'

                    recipe_images = EntityImage.where(entity_type_id: fi.id, entity_type: ENTITY_TYPE_FOOD_ITEM, status_id: CONTENT_STATUS_PUBLISHED).all

                    recipe_allergies = []
                    if fi.allergy_ids.present?
                        recipe_allergy_ids = fi.allergy_ids.split('@')
                        recipe_allergy_ids.each do |allergy_id|
                            ele = allergies.find{ |item| item['id'] == allergy_id.to_i }
                            if ele.present?
                                recipe_allergies << ele['name']
                            end
                        end
                    end

                    recipe_meal_types = []
                    if fi.meal_type_ids.present?
                        recipe_meal_type_ids = fi.meal_type_ids.split('@')
                        recipe_meal_type_ids.each do |meal_type_id|
                            ele = meal_types.find{ |item| item['id'] == meal_type_id.to_i }
                            if ele.present?
                                recipe_meal_types << ele['name']
                            end
                        end
                    end

                    recipes << {id: fi.id, name: fi.name, recipe_type: fi.recipe_type, ingredients_info: ingredients_info, price: price, currency: currency,recipe_images: recipe_images, allergies: recipe_allergies, meal_types: recipe_meal_types, serving_weight: serving_weight,is_jain: fi.is_jain,is_liquid: fi.is_liquid}
                end
            end
            if recipes.present?
                @category << {id: cat.id, name: cat.name, recipes: recipes}
            end
        end
        render "get_menu_template", layout: false
    end

    def menu_init
        unless has_sufficient_params(['menu_key'])
            return
        end
        user = User.includes(:languages,:entities,:published_logo).where(menu_key: params[:menu_key]).first
        unless user
            render_500_json 'User not present.'
            return
        end
        languages = user.languages
        user_languages = []
        if languages.present?
            languages.each do |language|
                obj = {}
                obj['id'] = language.master.id rescue nil
                obj['name'] = language.master.name rescue nil
                user_languages << obj
            end
        end
        entities = user.entities
        user_entities = []
        if entities.present?
            entities.each do |entity|
                obj = {}
                obj['id'] = entity.master.id rescue nil
                obj['name'] = entity.master.name rescue nil
                user_entities << obj
            end
        end
        logo_url = ''
        logo_image = user.published_logo
        if logo_image.present?
            logo_url = logo_image.url
        end
        map = {}
        map['id'] = user.id
        map['dining'] = user.dining
        map['take_away'] = user.take_away
        map['color1'] = user.color1
        map['color2'] = user.color2
        map['color3'] = user.color3
        map['languages'] = user_languages
        map['entities'] = user_entities
        map['logo'] = logo_url
        render_result_json map
    end

    def get_menu_template_v4
        unless has_sufficient_params(['menu_key','lang','entity'])
            return
        end

        user = User.includes(:entities,:published_logo,:published_hr_logo,:banner_images).where(menu_key: params[:menu_key]).first
        if user.visiting_count.present?
            visiting_count = user.visiting_count + 1
        else
            visiting_count = 1
        end
        user.update_columns(visiting_count: visiting_count)
        unless user
            render_500_json 'User not present.'
            return
        end

        if user.start_date.present? && Date.parse(user.start_date.to_s) > Date.parse(Time.now.to_s)
            render_500_json 'Restaurant Account is not Active yet.'
            return
        end

        if user.end_date.present? && Date.parse(user.end_date.to_s) < Date.parse(Time.now.to_s)
            render_500_json 'Restaurant Account is Expired.'
            return
        end

        if params[:entity] == 'undefined'
            user_entity = user.entities.first
        else
            user_entity = user.entities.where(user_id: user.id,entity_id: params[:entity]).first
            unless user_entity.present?
                render_500_json 'Something went wrong.'
                return
            end
        end

        if params[:lang] != 'undefined' && params[:lang].to_i != 0
            language = MastersLanguage.where(id: params[:lang]).first
            unless language
                render_500_json 'Something went wrong.'
                return
            end
            language = params[:lang]
        end

        categories_id = user.present? && user.qr_code_category.present? ? user.qr_code_category.split("@") : []

        categories = RestaurantCategory.includes([food_items: [:prices,:aliases,:images]]).where(id: categories_id).where(restaurant_id: user.id).where(status_id: CONTENT_STATUS_PUBLISHED).order('sort_by')

        logo_url = ''
        logo_image = user.published_logo
        if logo_image.present?
            logo_url = logo_image.url
        end

        meal_types = MEAL_TYPES

        allergies = ALLERGIES

        category = {}
        all_categories = []

        categories.each_with_index do |cat,index|
            recipes = []
            if index == 0
                cat.food_items.each do |fi|
                    if fi.status_id == CONTENT_STATUS_PUBLISHED
                        cooked_weight = fi.total_cooked_weight.to_f rescue 0
                        serving_weight = fi.per_serving_weight.to_f rescue 0

                        ingredients_info = fi.ingredients_info

                        price = fi.per_serving_selling_price
                        currency = user.currency.present? ? user.currency : '₹'

                        recipe_images = fi.images.where(status_id: CONTENT_STATUS_PUBLISHED).pluck(:url) rescue nil

                        recipe_allergies = []
                        if fi.allergy_ids.present?
                            recipe_allergy_ids = fi.allergy_ids.split('@')
                            recipe_allergy_ids.each do |allergy_id|
                                ele = allergies.find{ |item| item['id'] == allergy_id.to_i }
                                if ele.present?
                                    recipe_allergies << ele['name']
                                end
                            end
                        end

                        recipe_meal_types = []
                        if fi.meal_type_ids.present?
                            recipe_meal_type_ids = fi.meal_type_ids.split('@')
                            recipe_meal_type_ids.each do |meal_type_id|
                                ele = meal_types.find{ |item| item['id'] == meal_type_id.to_i }
                                if ele.present?
                                    recipe_meal_types << ele['name']
                                end
                            end
                        end

                        name = fi.name
                        food_alias = ''
                        if language.present?
                            food_aliases = fi.aliases
                            if food_aliases.present?
                                food_aliases.each do |ali|
                                    if ali.language_id == language.to_i
                                        name = ali.alias
                                    end
                                end
                            end
                        elsif language.to_i == 0
                            food_aliases = fi.aliases
                            if food_aliases.present?
                                food_aliases.each do |ali|
                                    if ali.language_id == 2 || ali.language_id == 3
                                        food_alias = ali.alias
                                    end
                                end
                            end
                        end

                        price = 0
                        food_prices = fi.prices
                        if food_prices.present?
                            food_prices.each do |food_price|
                                if food_price.entity_id == user_entity.entity_id
                                    price = food_price.price
                                end
                            end
                        end

                        # price = fi.prices.where(entity_id: params[:entity]).first.price rescue nil

                        recipes << {id: fi.id, name: name, recipe_type: fi.recipe_type, ingredients_info: ingredients_info, price: price, currency: currency,recipe_images: recipe_images, allergies: recipe_allergies, meal_types: recipe_meal_types, serving_weight: serving_weight,is_jain: fi.is_jain,is_liquid: fi.is_liquid, category_id: fi.category_id,alias: food_alias, quantity: 0}
                    end
                end
            end
            category = {id: cat.id, name: cat.name, recipes: recipes}
            all_categories << category
        end
        restaurant_types = []
        if user.restaurant_type.present?
            types = user.restaurant_type.split('@')
            types.each_with_index do |type,index|
                obj = {}
                obj['id'] = index + 1
                obj['type'] = type
                restaurant_types << obj
            end
        end
        obj = {}
        obj['categories'] = all_categories
        obj['user'] = user.as_json(only: [:name, :tagline, :mobile_no, :website, :address, :map_link, :country_code, :color1, :color2, :color3, :image_access])
        obj['user']['restaurant_types'] = restaurant_types
        obj['user']['logo'] = logo_url
        # if user.id == 3
        #     obj['slider_images'] = ['https://firebasestorage.googleapis.com/v0/b/foodformula-f69fa.appspot.com/o/1.JPG?alt=media&token=62931aa3-4a03-4509-9d2c-a174c03b302a','https://firebasestorage.googleapis.com/v0/b/foodformula-f69fa.appspot.com/o/2.JPG?alt=media&token=8205863d-a7be-4f4d-8a23-f95b00454fa5']
        #     obj['hr_logo'] = 'https://firebasestorage.googleapis.com/v0/b/foodformula-f69fa.appspot.com/o/1111.JPG?alt=media&token=4e4d622a-334e-4533-b690-a9f9e156976c'
        # else
        slider_images = []
        if user.banner_images
            slider_images = user.banner_images.pluck(:url)
        end
        hr_logo = ''
        if user.published_hr_logo.present?
            hr_logo = user.published_hr_logo.url
        end
        obj['slider_images'] = slider_images
        obj['hr_logo'] = hr_logo
        obj['take_away'] = user.take_away
        obj['dining'] = user.dining
        obj['currency'] = user.currency
        # end

        render_result_json obj
    end

    def get_menu_template_v3
        unless has_sufficient_params(['menu_key'])
            return
        end

        user = User.where(menu_key: params[:menu_key]).first
        unless user
            render_500_json 'User not present.'
            return
        end

        if user.start_date.present? && Date.parse(user.start_date.to_s) > Date.parse(Time.now.to_s)
            render_500_json 'Your Account is not Active yet.'
            return
        end

        if user.end_date.present? && Date.parse(user.end_date.to_s) < Date.parse(Time.now.to_s)
            render_500_json 'Your Account is Expired.'
            return
        end

        lang = params['lang'].present? ? params['lang'] : 'eng'

        categories_id = user.present? && user.qr_code_category.present? ? user.qr_code_category.split("@") : []

        categories = RestaurantCategory.includes(:food_items).where(id: categories_id).where(restaurant_id: user.id).where(status_id: CONTENT_STATUS_PUBLISHED).order('name')

        logo_image = EntityImage.where(entity_type_id: user.id, entity_type: ENTITY_TYPE_LOGO, status_id: CONTENT_STATUS_PUBLISHED).first

        meal_types = MEAL_TYPES

        allergies = ALLERGIES

        category = {}
        all_categories = []

        categories.each_with_index do |cat,index|
            recipes = []
            if index == 0
                cat.food_items.order(:sort_by).each do |fi|
                    if fi.status_id == CONTENT_STATUS_PUBLISHED
                        cooked_weight = fi.total_cooked_weight.to_f rescue 0
                        serving_weight = fi.per_serving_weight.to_f rescue 0

                        ingredients_info = fi.ingredients_info

                        price = fi.per_serving_selling_price
                        currency = user.currency.present? ? user.currency : '₹'

                        recipe_images = EntityImage.where(entity_type_id: fi.id, entity_type: ENTITY_TYPE_FOOD_ITEM, status_id: CONTENT_STATUS_PUBLISHED).pluck(:url)

                        recipe_allergies = []
                        if fi.allergy_ids.present?
                            recipe_allergy_ids = fi.allergy_ids.split('@')
                            recipe_allergy_ids.each do |allergy_id|
                                ele = allergies.find{ |item| item['id'] == allergy_id.to_i }
                                if ele.present?
                                    recipe_allergies << ele['name']
                                end
                            end
                        end

                        recipe_meal_types = []
                        if fi.meal_type_ids.present?
                            recipe_meal_type_ids = fi.meal_type_ids.split('@')
                            recipe_meal_type_ids.each do |meal_type_id|
                                ele = meal_types.find{ |item| item['id'] == meal_type_id.to_i }
                                if ele.present?
                                    recipe_meal_types << ele['name']
                                end
                            end
                        end

                        recipes << {id: fi.id, name: fi.name, recipe_type: fi.recipe_type, ingredients_info: ingredients_info, price: price, currency: currency,recipe_images: recipe_images, allergies: recipe_allergies, meal_types: recipe_meal_types, serving_weight: serving_weight,is_jain: fi.is_jain,is_liquid: fi.is_liquid, category_id: fi.category_id}
                    end
                end
            end
            # if recipes.present?
                category = {id: cat.id, name: cat.name, recipes: recipes}
                all_categories << category
            # end
        end
        restaurant_types = []
        if user.restaurant_type.present?
            types = user.restaurant_type.split('@')
            types.each_with_index do |type,index|
                obj = {}
                obj['id'] = index + 1
                obj['type'] = type
                restaurant_types << obj
            end
        end
        obj = {}
        obj['categories'] = all_categories
        # obj['logo'] = logo_image.url
        obj['user'] = user.as_json(only: [:name, :tagline, :address])
        obj['user']['restaurant_types'] = restaurant_types
        render_result_json obj
    end

    def get_recipe_details_from_category
        unless has_sufficient_params(['menu_key','category_id','entity','lang'])
            return
        end

        user = User.includes(:entities).where(menu_key: params[:menu_key]).first
        unless user
            render_500_json 'User not present.'
            return
        end

        if user.start_date.present? && Date.parse(user.start_date.to_s) > Date.parse(Time.now.to_s)
            render_500_json 'Your Account is not Active yet.'
            return
        end

        if user.end_date.present? && Date.parse(user.end_date.to_s) < Date.parse(Time.now.to_s)
            render_500_json 'Your Account is Expired.'
            return
        end

        if params[:entity] == 'undefined'
            user_entity = user.entities.first
        else
            user_entity = user.entities.where(user_id: user.id,entity_id: params[:entity]).first
            unless user_entity.present?
                render_500_json 'Something went wrong.'
                return
            end
        end

        if params[:lang] != 'undefined' && params[:lang].to_i != 0
            language = MastersLanguage.where(id: params[:lang]).first
            unless language
                render_500_json 'Something went wrong.'
                return
            end
            language = params[:lang]
        end

        categories_id = params[:category_id]

        categories = RestaurantCategory.includes([food_items: [:prices,:aliases,:images]]).where(id: categories_id).where(restaurant_id: user.id).where(status_id: CONTENT_STATUS_PUBLISHED).order('name')

        # logo_image = EntityImage.where(entity_type_id: user.id, entity_type: 2, status_id: 1).first

        meal_types = MEAL_TYPES

        allergies = ALLERGIES

        category = {}
        all_categories = []

        recipes = []
        categories.each do |cat|
            cat.food_items.each do |fi|
                if fi.status_id == CONTENT_STATUS_PUBLISHED
                    cooked_weight = fi.total_cooked_weight.to_f rescue 0
                    serving_weight = fi.per_serving_weight.to_f rescue 0

                    ingredients_info = fi.ingredients_info

                    price = fi.per_serving_selling_price
                    currency = user.currency.present? ? user.currency : '₹'

                    recipe_images = fi.images.where(status_id: CONTENT_STATUS_PUBLISHED).pluck(:url)

                    recipe_allergies = []
                    if fi.allergy_ids.present?
                        recipe_allergy_ids = fi.allergy_ids.split('@')
                        recipe_allergy_ids.each do |allergy_id|
                            ele = allergies.find{ |item| item['id'] == allergy_id.to_i }
                            if ele.present?
                                recipe_allergies << ele['name']
                            end
                        end
                    end

                    recipe_meal_types = []
                    if fi.meal_type_ids.present?
                        recipe_meal_type_ids = fi.meal_type_ids.split('@')
                        recipe_meal_type_ids.each do |meal_type_id|
                            ele = meal_types.find{ |item| item['id'] == meal_type_id.to_i }
                            if ele.present?
                                recipe_meal_types << ele['name']
                            end
                        end
                    end

                    name = fi.name
                    food_alias = ''
                    if language.present?
                        food_aliases = fi.aliases
                        if food_aliases.present?
                            food_aliases.each do |ali|
                                if ali.language_id == language.to_i
                                    name = ali.alias
                                end
                            end
                        end
                    elsif language.to_i == 0
                        food_aliases = fi.aliases
                        if food_aliases.present?
                            food_aliases.each do |ali|
                                if ali.language_id == 2 || ali.language_id == 3
                                    food_alias = ali.alias
                                end
                            end
                        end
                    end

                    price = 0
                    food_prices = fi.prices
                    if food_prices.present?
                        food_prices.each do |food_price|
                            if food_price.entity_id == user_entity.entity_id
                                price = food_price.price
                            end
                        end
                    end


                    recipes << {id: fi.id, name: name, recipe_type: fi.recipe_type, ingredients_info: ingredients_info, price: price, currency: currency,recipe_images: recipe_images, allergies: recipe_allergies, meal_types: recipe_meal_types, serving_weight: serving_weight,is_jain: fi.is_jain,is_liquid: fi.is_liquid, category_id: fi.category_id,alias: food_alias, quantity: 0}
                end
            end
        end
        obj = {}
        obj['recipes'] = recipes
        # obj['logo'] = logo_image.url
        # obj['user'] = user
        render_result_json obj
    end

    def generate_enquiry
        unless has_sufficient_params(['name','email'])
            return
        end
        enquiry = Enquiry.new
        enquiry.name = params[:name]
        enquiry.email = params[:email]
        enquiry.mobile_no = params[:mobile_no] if params[:mobile_no].present?
        enquiry.city = params[:city]
        enquiry.message = params[:message]
        enquiry.status_id = CONTENT_STATUS_PUBLISHED
        enquiry.save

        render_success_json 'Enquiry generated.'
    end

    def get_all_enquiries
        enquiries = Enquiry.all
        render_result_json enquiries
    end

    def store_image
        unless has_sufficient_params(['entity_type','entity_type_id','url'])
            return
        end
        if params[:entity_type].to_i == ENTITY_TYPE_LOGO
            old_restaurant_logo = EntityImage.where(entity_type: ENTITY_TYPE_LOGO,entity_type_id: params[:entity_type_id],status_id: CONTENT_STATUS_PUBLISHED).first
            if old_restaurant_logo.present?
                old_restaurant_logo.update_attributes(status_id: CONTENT_STATUS_DRAFT)
            end
        end
        image = EntityImage.new
        image.entity_type = params[:entity_type]
        image.entity_type_id = params[:entity_type_id]
        image.url = params[:url]
        image.status_id = CONTENT_STATUS_PUBLISHED
        if image.save
            obj = {}
            obj['id'] = image.id
            obj['url'] = image.url
            render_result_json obj
        else
            render_500_json 'Something went wrong !'
        end
    end

    def remove_image
        unless has_sufficient_params(['id'])
            return
        end
        image = EntityImage.find params['id']
        unless image
            render_500_json 'Image not present.'
        end
        image.update_attributes(status_id: CONTENT_STATUS_DRAFT)
        render_success_json 'Image removed.'
    end

    def get_restaurant_logo
        unless has_sufficient_params(['restaurant_id'])
            return
        end
        map = {}
        user = User.includes(:published_logo,:published_hr_logo,:banner_images).where(id: params[:restaurant_id]).first
        unless user
            render_500_json 'Restaurant not present.'
        end
        response_obj = {}

        response_obj['logo'] = {}
        if user.published_logo.present?
            obj = {}
            obj['id'] = user.published_logo.id
            obj['url'] = user.published_logo.url
            response_obj['logo'] = obj
        end

        response_obj['hr_logo'] = {}
        if user.published_hr_logo.present?
            obj = {}
            obj['id'] = user.published_hr_logo.id
            obj['url'] = user.published_hr_logo.url
            response_obj['hr_logo'] = obj
        end


        response_obj['banner_images'] = []
        if user.banner_images.present?
            banner_images = []
            user.banner_images.each do |banner_image|
                obj = {}
                obj['id'] = banner_image.id
                obj['url'] = banner_image.url
                banner_images << obj
            end
            response_obj['banner_images'] = banner_images
        end
        
        render_result_json response_obj
    end

    def copy_recipe
        unless has_sufficient_params(['id'])
            return
        end
        
        food_item = MastersFoodItem.where(id: params[:id]).first
        if food_item.present?
            recipe = food_item.dup
            recipe.status_id = CONTENT_STATUS_DRAFT

            if recipe.save
                map = {'id': recipe.id}
                render_result_json map
            end
        end
    end

    def set_recipe_category
        unless has_sufficient_params(['list'])
            return
        end

        params[:list].each_with_index do |item, index|
            MastersFoodItem.find(item[:id]).update_attributes(sort_by: index)
        end

        render_success_json 'Order updated'
    end

    def set_category_order
        unless has_sufficient_params(['list'])
            return
        end

        params[:list].each_with_index do |item, index|
            RestaurantCategory.find(item[:id]).update_attributes(sort_by: index)
        end

        render_success_json 'Order updated'
    end

    def export_recipes
        unless has_sufficient_params(['restaurant_id'])
            return
        end
        @restaurant = User.find params[:restaurant_id]
        food_items = MastersFoodItem.includes(:category).where(restaurant_id: params[:restaurant_id]).all
        column_names = ['Name','Category','Status','Ingredients','Type','Cooked Weight','Serving Description','Per Serving Unit','Per Serving Cost Price','Per Serving Selling Price','Cooking Info','Allergies Info','Expiry Date','Meal Type Info']

        @csv = CSV.generate do |csv|
            csv << column_names
            food_items.each do |fi|
                arr = []
                arr[0] = fi.name
                arr[1] = fi.category.name
                arr[2] = fi.ingredients_info
                if fi.status_id.present?
                    if fi.recipe_type == CONTENT_STATUS_PUBLISHED
                        arr[3] = 'Published'
                    else
                        arr[3] = 'Draft'
                    end
                end
                if fi.recipe_type.present?
                    if fi.recipe_type == RECIPE_TYPE_VEG
                        arr[4] = 'Veg.'
                    else
                        arr[4] = 'Non Veg.'
                    end
                end
                arr[5] = fi.total_cooked_weight
                arr[6] = fi.serving_description
                arr[7] = fi.per_serving_weight
                arr[8] = fi.per_serving_cost_price
                arr[9] = fi.per_serving_selling_price
                arr[10] = fi.cooking_info
                arr[11] = fi.allergies_info
                arr[12] = fi.expiry_date
                arr[13] = fi.meal_types_info
                csv << arr
            end
        end

        respond_to do |format|
            format.html
            format.csv { send_data @csv, filename: "#{@restaurant.name.downcase}-recipes-#{Date.today}.csv" }
        end

    end

    def food_item_label
        unless has_sufficient_params(['id','restaurant_id'])
            return
        end
        # obj = {}
        food = MastersFoodItem.where(id: params[:id]).first.as_json
        recipe_image = EntityImage.where(entity_type: ENTITY_TYPE_FOOD_ITEM, entity_type_id: params[:id]).first
        if recipe_image.present?
            recipe_url = recipe_image.url
        end
        logo = EntityImage.where(entity_type: ENTITY_TYPE_LOGO, entity_type_id: params[:restaurant_id]).first
        if logo.present?
            logo_url = logo.url
        end
        food['recipe_url'] = recipe_url
        food['logo_url'] = logo_url

        render_result_json food
    end

    def get_menu
        unless has_sufficient_params(['category_ids'])
            return
        end

        user = User.where(id: params[:restaurant_id]).first
        # categories = RestaurantCategory.includes(:food_items).where(id: params['category_ids']).where(restaurant_id: user.id).where(status_id: CONTENT_STATUS_PUBLISHED)
        categories = RestaurantCategory.includes([food_items: [:prices,:aliases,:images]]).where(id: params['category_ids']).where(restaurant_id: user.id).where(status_id: CONTENT_STATUS_PUBLISHED).order('sort_by')
        map = []

        if params[:entity] == 'undefined' || !params[:entity].present?
            user_entity = user.entities.first
        else
            user_entity = user.entities.where(user_id: user.id,entity_id: params[:entity]).first
            unless user_entity.present?
                render_500_json 'Something went wrong.'
                return
            end
        end

        if params[:lang] != 'undefined' && params[:lang].to_i != 0
            language = MastersLanguage.where(id: params[:lang]).first
            unless language
                render_500_json 'Something went wrong.'
                return
            end
            language = params[:lang]
        end

        categories.each do |cat|
            recipes = []
            cat.food_items.order(:sort_by).each do |r|
                if r.status_id == CONTENT_STATUS_PUBLISHED

                    ingredients_info = r.ingredients_info rescue ''
                    # price = r.per_serving_selling_price
                    # url = "https://dubai.fitterfly.in/restaurant/nutrition_facts_nutrical?key=#{r.unique_token}"
                    url = 'NA'
                    image_url = ''
                    image = EntityImage.where(entity_type: ENTITY_TYPE_FOOD_ITEM,entity_type_id: r.id).first
                    if image.present?
                        image_url = image.url
                    end

                    serving_weight = r.per_serving_weight.to_f rescue 0

                    meal_types = MEAL_TYPES

                    allergies = ALLERGIES

                    recipe_allergies = []
                    if r.allergy_ids.present?
                        recipe_allergy_ids = r.allergy_ids.split('@')
                        recipe_allergy_ids.each do |allergy_id|
                            ele = allergies.find{ |item| item['id'] == allergy_id.to_i }
                            if ele.present?
                                recipe_allergies << ele['name']
                            end
                        end
                    end

                    recipe_meal_types = []
                    if r.meal_type_ids.present?
                        recipe_meal_type_ids = r.meal_type_ids.split('@')
                        recipe_meal_type_ids.each do |meal_type_id|
                            ele = meal_types.find{ |item| item['id'] == meal_type_id.to_i }
                            if ele.present?
                                recipe_meal_types << ele['name']
                            end
                        end
                    end

                    name = r.name
                    food_alias = ''
                    if language.present?
                        food_aliases = r.aliases
                        if food_aliases.present?
                            food_aliases.each do |ali|
                                if ali.language_id == language.to_i
                                    name = ali.alias
                                end
                            end
                        end
                    elsif language.to_i == 0
                        food_aliases = r.aliases
                        if food_aliases.present?
                            food_aliases.each do |ali|
                                if ali.language_id == 2 || ali.language_id == 3
                                    food_alias = ali.alias
                                end
                            end
                        end
                    end

                    price = 0
                    food_prices = r.prices
                    if food_prices.present?
                        food_prices.each do |food_price|
                            if food_price.entity_id == user_entity.entity_id
                                price = food_price.price
                            end
                        end
                    end

                    recipes << {id: r.id, name: name.titlecase, ingredients_info: ingredients_info, price: price, url: url,image_url: image_url,recipe_type: r.recipe_type, allergies: recipe_allergies, meal_types: recipe_meal_types, serving_weight: serving_weight,is_jain: r.is_jain,is_liquid: r.is_liquid}
                end
            end
            map << {name: cat.name, recipes: recipes}
        end

        render_result_json map
    end

    def update_enquiry
        unless has_sufficient_params(['id'])
            return
        end
        enquiry = Enquiry.where(id: params[:id]).first
        if enquiry.present?
            enquiry.update_attributes(status_id: params[:status_id])
        end
        render_success_json 'Enquiry Updated.'
    end

    def remove_enquiry
        unless has_sufficient_params(['id'])
            return
        end
        enquiry = Enquiry.where(id: params[:id]).first
        if enquiry.present?
            enquiry.delete
        end
        render_success_json 'Enquiry Removed.'
    end

    def get_enquiry_by_id
        unless has_sufficient_params(['id'])
            return
        end
        enquiry = Enquiry.where(id: params[:id]).first
        unless enquiry
            render_500_json 'Enquiry not present.'
            return
        end
        render_result_json enquiry
    end

    def update_food_item_prices
        unless has_sufficient_params(['entity_prices','food_item_id'])
            return
        end
        food_item_id = params[:food_item_id]
        entity_prices = params[:entity_prices]
        entity_prices.each do |entity_price|
            id = entity_price['id']
            price = sprintf('%.2f', entity_price['price'])
            if id.present?
                food_item_price = FoodItemPrice.where(id: id).first
                food_item_price.price = price
                food_item_price.save
            else
                food_item_price = FoodItemPrice.where(food_item_id: food_item_id,entity_id: entity_price['id']).first
                if !food_item_price.present?
                    food_item_price = FoodItemPrice.new
                end
                food_item_price.food_item_id = food_item_id
                food_item_price.entity_id = entity_price['entity_id']
                food_item_price.price = price
                food_item_price.save
            end
        end
        render_success_json 'Food Item prices updated.'
    end

    def update_food_item_aliases
        unless has_sufficient_params(['food_item_aliases','food_item_id'])
            return
        end
        food_item_id = params[:food_item_id]
        food_item_aliases = params[:food_item_aliases]
        food_item_aliases.each do |ali|
            id = ali['id']
            language_id = ali['language_id']
            food_alias = ali['alias']
            if id.present?
                food_item_alias = FoodItemAlias.where(id: id).first
                food_item_alias.alias = food_alias
                food_item_alias.save
            else
                food_item_alias = FoodItemAlias.where(food_item_id: food_item_id,language_id: language_id).first
                if !food_item_alias.present?
                    food_item_alias = FoodItemAlias.new
                end
                food_item_alias.food_item_id = food_item_id
                food_item_alias.language_id = language_id
                food_item_alias.alias = food_alias
                food_item_alias.save
            end
        end
        render_success_json 'Food Item Aliases updated.'
    end

end
