class AdminController < ApplicationController

    before_action :authenticate_admin, except: [:create_admin,:request_account_access]

    def create_admin
        unless has_sufficient_params(['email'])
            return
        end

        admin = Admin.where(email: params[:email]).first
        if admin
            render_500_json "This email is already registered with us."
            return
        end

        admin = Admin.new
        admin.email = params[:email]
        admin.status_id = params[:status_id]
        admin.password = params[:password]
        admin.sign_in_count = 0

        if admin.save
            render_result_json admin
        else
            render_500_json admin.errors.full_messages.first
        end
    end

    def update_password
        unless has_sufficient_params(['old_password', 'new_password','retype_new_password'])
            return
        end

        if params[:new_password] != params[:retype_new_password]
            render_500_json 'Password dose not match'
            return
        end

        unless @admin.valid_password?(params[:old_password])
            render_500_json "Old password dosen't match"
            return
        end

        @admin.password = params[:new_password]
        @admin.save(validate: false)

        render_success_json "New password updated successfully"
    end

    def get_admin_profile
        admin = @admin
        render_result_json admin
    end

    def update_admin_profile
        unless has_sufficient_params(['admin_id'])
            return
        end

        admin = Admin.where(id: params[:admin_id]).first
        unless admin
            render_500_json "Admin not found!"
            return
        end

        admin.status_id = params[:status_id] if params[:status_id].present?

        if admin.save
            obj = {id: admin.id, email: admin.email, status_id: admin.status_id}
            render_result_json obj
        else
            render_500_json admin.errors.full_messages.first
        end
    end

    def create_user
        unless has_sufficient_params(['email'])
            return
        end

        user = User.where('email ilike ?', params[:email].strip).first
        if user
            render_500_json "This email is already registered with us."
            return
        end
        user = User.where('username ilike ?', params[:username].strip).first
        if user
            render_500_json "This username is already registered with us."
            return
        end

        user = User.new
        user.name = params[:name].strip.titleize if params[:name].present?
        user.email = params[:email].strip.downcase if params[:email].present?
        user.username = params[:username].strip.downcase if params[:username].present?
        user.currency = params[:currency]
        user.start_date = params[:start_date]
        user.end_date = params[:end_date]
        user.enable_access_state = params[:enable_access_state] if params[:enable_access_state].present?
        user.mobile_no = params[:mobile_no]
        user.status_id = params[:status_id] if params[:status_id].present?
        user.website = params[:website].strip.downcase if params[:website].present?
        user.manager_name = params[:manager_name].strip.titleize if params[:manager_name].present?
        user.country = params[:country] if params[:country].present?
        user.tagline = params[:tagline] if params[:tagline].present?
        user.restaurant_type = params[:restaurant_type].downcase if params[:restaurant_type].present?
        user.address = params[:address]
        user.dining = params[:dining]
        user.take_away = params[:take_away]
        user.image_access = params[:image_access]
        user.password = 123456
        user.sign_in_count = 0

        if user.save
            render_success_json 'User created.'
        else
            render_500_json user.errors.full_messages.first
        end
    end

    def get_user_profile
        unless has_sufficient_params(['user_id'])
            return
        end

        user = User.includes([entities: :master],[languages: :master]).where(id: params[:user_id]).first
        if user.present?
            entity_arr = []
            user_entities = user.entities
            if user_entities.present?
                user_entities.each do |entity|
                    obj = {}
                    obj['id'] = entity.id
                    obj['name'] = entity.master.name
                    entity_arr << obj
                end
            end

            language_arr = []
            user_languages = user.languages
            if user_languages.present?
                user_languages.each do |language|
                    obj = {}
                    obj['id'] = language.id
                    obj['name'] = language.master.name
                    language_arr << obj
                end
            end
            user = user.as_json
            user['user_entities'] = entity_arr
            user['user_languages'] = language_arr

            render_result_json user
        else
            render_500_json 'User not present.'
        end
    end

    def update_user_profile
        unless has_sufficient_params(['user_id'])
            return
        end

        user = User.where('lower(email) = ?', params[:email].strip.downcase).first
        if user && user.id != params[:id]
            render_500_json "This email is already registered with us."
            return
        end
        user = User.where('lower(username) = ?', params[:username].strip.downcase).first
        if user && user.id != params[:id]
            render_500_json "This username is already registered with us."
            return
        end

        user = User.where(id: params[:id]).first
        unless user
            render_500_json "user not found!"
            return
        end

        user.name = params[:name].strip.titleize if params[:name].present?
        user.email = params[:email].strip.downcase if params[:email].present?
        user.username = params[:username].strip.downcase if params[:username].present?
        user.currency = params[:currency]
        user.start_date = params[:start_date]
        user.end_date = params[:end_date]
        user.enable_access_state = params[:enable_access_state] if params[:enable_access_state].present?
        user.mobile_no = params[:mobile_no]
        user.status_id = params[:status_id] if params[:status_id].present?
        user.website = params[:website].strip.downcase if params[:website].present?
        user.manager_name = params[:manager_name].strip.titleize if params[:manager_name].present?
        user.tagline = params[:tagline] if params[:tagline].present?
        user.country = params[:country] if params[:country].present?
        user.restaurant_type = params[:restaurant_type].downcase if params[:restaurant_type].present?
        user.address = params[:address]
        user.dining = params[:dining]
        user.take_away = params[:take_away]
        user.map_link = params[:map_link]
        user.country_code = params[:country_code]
        user.image_access = params[:image_access]

        if user.save
            render_success_json 'User updated.'
        else
            render_500_json user.errors.full_messages.first
        end
    end

    def request_account_access
        unless has_sufficient_params(['email','password'])
            return
        end

        admin = Admin.where('email ilike ?', params[:email]).first
        
        unless admin
            render_500_json 'Invalid Access. Please check your Email and Password.'
            return
        end

        unless admin.valid_password?(params[:password])
            render_500_json 'Invalid Access. Please check your Email and Password.'
            return
        end

        unless admin.status_id == 1
            render_500_json 'Your Account is not Active yet.'
            return
        end

        unless admin.sign_in_count.present?
            admin.sign_in_count = 0
        else
            admin.sign_in_count = admin.sign_in_count + 1
        end

        admin.last_sign_in_at = admin.current_sign_in_at
        admin.current_sign_in_at = Time.now
        admin.save

        map = {}
        map['email'] = admin.email
        map['api_key'] = admin.api_key
        map['access_state'] = admin.status_id
        map['admin_id'] = admin.id
        map['sign_in_count'] = admin.sign_in_count
        map['is_admin'] = true

        render_result_json map
    end

    def get_all_users
        users = User.all.select(:id,:name,:email,:username,:status_id,:enable_access_state).as_json
        users.each do |user|
            # user['recipe_count'] = MastersFoodItem.where(restaurant_id: user['id']).count rescue 0
            user['recipe_count'] = MastersFoodItem.where('restaurant_id = ? AND (status_id = ? OR status_id = ?)',user['id'],1,2).count rescue 0
            # user['category_count'] = RestaurantCategory.where(restaurant_id: user['id']).count rescue 0
            user['category_count'] = RestaurantCategory.where('restaurant_id = ? AND status_id = ?',user['id'],1).count rescue 0
        end
        render_result_json users
    end

    def add_or_update_language

        if params[:id].present?
            language = MastersLanguage.where(id: params[:id]).first
            unless language
                render_500_json 'Language not found.'
                return
            end
            language.name = params[:name] if params[:name].present?
            language.status_id = params[:status_id] if params[:status_id].present?
            language.save

            render_success_json 'Language updated.'
        else
            unless has_sufficient_params(['name'])
                return
            end
            language = MastersLanguage.where('trim(name) ilike (?)',params[:name].strip).first
            if language.present?
                render_500_json 'Language with same name already present.'
                return
            end
            language = MastersLanguage.new
            language.name = params[:name]
            language.status_id = params[:status_id].present? ? params[:status_id] : CONTENT_STATUS_PUBLISHED
            language.save

            render_result_json language
        end
    end

    def get_all_masters_languages
        masters_languages = MastersLanguage.all
        render_result_json masters_languages
    end

    def get_language_by_id
        unless has_sufficient_params(['id'])
            return
        end
        language = MastersLanguage.where(id: params[:id]).first
        unless language
            render_500_json 'Language not found.'
            return
        end
        render_result_json language
    end

    def get_master
        masters_entities = MastersEntity.published.select(:id,:name).all
        masters_languages = MastersLanguage.published.select(:id,:name).all
        obj = {}
        obj['masters_entities'] = masters_entities
        obj['masters_languages'] = masters_languages
        render_result_json obj
    end

end
