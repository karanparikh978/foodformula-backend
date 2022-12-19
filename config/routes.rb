Rails.application.routes.draw do
    devise_for :users
    get 'welcome/index'
    devise_for :admins
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
    root 'welcome#index'

    namespace :admin do
        match 'create_admin', via: [ :post, :options]
        match 'update_password', via: [ :post, :options]
        match 'get_admin_profile', via: [ :post, :options]
        match 'update_admin_profile', via: [ :post, :options]
        match 'request_account_access', via: [ :post, :options]
        match 'get_all_users', via: [ :post, :options]
        match 'get_user_profile', via: [ :post, :options]
        match 'update_user_profile', via: [ :post, :options]
        match 'create_user', via: [ :post, :options]
        match 'add_or_update_language', via: [ :post, :options]
        match 'get_all_masters_languages', via: [ :post, :options]
        match 'get_language_by_id', via: [ :post, :options]
        match 'get_master', via: [ :post, :options]
    end

    namespace :user do
        match 'create_user', via: [ :post, :options]
        match 'update_password', via: [ :post, :options]
        match 'get_user_profile', via: [ :post, :options]
        match 'get_master', via: [ :post, :options]
        match 'request_account_access', via: [ :post, :options]
        match 'update_user_profile', via: [ :post, :options]
    end

    namespace :restaurant do
        match 'create_category', via: [ :post, :options]
        match 'remove_category', via: [ :post, :options]
        match 'update_category', via: [ :post, :options]
        match 'add_or_update_category', via: [ :post, :options]
        match 'get_all_categories', via: [ :post, :options]
        match 'create_food_item', via: [ :post, :options]
        match 'get_food_item_details_by_id', via: [ :post, :options]
        match 'update_food_item', via: [ :post, :options]
        match 'remove_food_item', via: [ :post, :options]
        match 'get_recipes_by_category', via: [ :post, :options]
        match 'create_food_item_in_bulk', via: [ :post, :options]
        match 'search_recipe', via: [ :post, :options]
        match 'get_qr_code_category', via: [ :post, :options]
        match 'update_qr_code_category', via: [ :post, :options]
        match 'get_menu_template', via: [ :get]
        match 'get_menu_template_v4', via: [ :post, :options]
        match 'menu_init', via: [ :post, :options]
        match 'get_menu_template_v3', via: [ :post, :options]
        match 'generate_enquiry', via: [ :post, :options]
        match 'get_all_enquiries', via: [ :post, :options]
        match 'store_image', via: [ :post, :options]
        match 'remove_image', via: [ :post, :options]
        match 'get_restaurant_logo', via: [ :post, :options]
        match 'copy_recipe', via: [ :post, :options]
        match 'set_recipe_category', via: [ :post, :options]
        match 'set_category_order', via: [ :post, :options]
        match 'export_recipes', via: [ :get]
        match 'food_item_label', via: [ :post, :options]
        match 'get_menu', via: [ :post, :options]
        match 'update_enquiry', via: [ :post, :options]
        match 'remove_enquiry', via: [ :post, :options]
        match 'get_enquiry_by_id', via: [ :post, :options]
        match 'get_recipe_details_from_category', via: [ :post, :options]
        match 'update_food_item_prices', via: [ :post, :options]
        match 'update_food_item_aliases', via: [ :post, :options]
    end

    namespace :entity do
        match 'add_or_update_entity', via: [ :post, :options]
        match 'get_all_masters_entities', via: [ :post, :options]
        match 'get_entity_by_id', via: [ :post, :options]
        match 'create_user_entity', via: [ :post, :options]
        match 'remove_user_entity', via: [ :post, :options]
        match 'create_user_language', via: [ :post, :options]
        match 'remove_user_language', via: [ :post, :options]
    end

    namespace :language do
        match 'add_or_update_language', via: [ :post, :options]
        match 'get_all_masters_languages', via: [ :post, :options]
        match 'get_language_by_id', via: [ :post, :options]
        match 'create_user_language', via: [ :post, :options]
        match 'remove_user_language', via: [ :post, :options]
    end

    namespace :order do
        match 'generate_order', via: [ :post, :options]
        match 'get_order_details', via: [ :post, :options]
        match 'get_restaurant_orders', via: [ :post, :options]
        match 'update_order', via: [ :post, :options]
        match 'get_end_user_orders', via: [ :post, :options]
    end

end
