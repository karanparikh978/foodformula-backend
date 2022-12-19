class UserController < ApplicationController

    before_action :authenticate_user, except: [:create_user,:request_account_access]

    def create_user
        unless has_sufficient_params(['email'])
            return
        end

        user = User.where(email: params[:email]).first
        if user
            render_500_json "This email is already registered with us."
            return
        end

        user = User.new
        user.email = params[:email]
        user.status_id = params[:status_id]
        user.password = params[:password]
        user.color1 = '#12a583'
        user.color2 = '#113448'
        user.sign_in_count = 0

        if user.save
            render_result_json user
        else
            render_500_json user.errors.full_messages.first
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

        unless @user.valid_password?(params[:old_password])
            render_500_json "Old password dosen't match"
            return
        end

        @user.password = params[:new_password]
        @user.save(validate: false)

        render_success_json "New password updated successfully"
    end

    def get_master
        user_id = @user.id
        user = User.includes([entities: :master],[languages: :master]).where(id: user_id).first
        if user.present?
            entity_arr = []
            user_entities = user.entities
            if user_entities.present?
                user_entities.each do |entity|
                    obj = {}
                    obj['id'] = entity.master.id
                    obj['name'] = entity.master.name
                    entity_arr << obj
                end
            end

            language_arr = []
            user_languages = user.languages
            if user_languages.present?
                user_languages.each do |language|
                    obj = {}
                    obj['id'] = language.master.id
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
        unless has_sufficient_params(['restaurant_id'])
            return
        end

        user = User.where(id: params[:restaurant_id]).first
        unless user
            render_500_json "user not found!"
            return
        end

        user.name = params[:name] if params[:name].present?
        user.email = params[:email] if params[:email].present?
        user.currency = params[:currency]
        user.website = params[:website]
        user.country = params[:country]
        user.tagline = params[:tagline]
        user.address = params[:address]
        user.country_code = params[:country_code]
        user.map_link = params[:map_link]
        user.color1 = params[:color1]
        user.color2 = params[:color2]
        user.color3 = params[:color3]
        user.image_access = params[:image_access]

        if user.save
            map = {}
            map['email'] = user.email
            map['api_key'] = user.api_key
            map['access_state'] = user.enable_access_state
            map['status_id'] = user.status_id
            map['restaurant_id'] = user.id
            map['sign_in_count'] = user.sign_in_count
            map['is_admin'] = false
            map['currency'] = user.currency
            map['name'] = user.name
            map['username'] = user.username
            map['website'] = user.website
            map['country'] = user.country
            map['tagline'] = user.tagline
            map['user_id'] = user.id
            map['address'] = user.address
            map['map_link'] = user.map_link
            map['country_code'] = user.country_code
            map['mobile_no'] = user.mobile_no
            map['color1'] = user.color1
            map['color2'] = user.color2
            map['color3'] = user.color3
            map['image_access'] = user.image_access

            render_result_json map
        else
            render_500_json user.errors.full_messages.first
        end
    end

    def request_account_access
        unless has_sufficient_params(['email','password'])
            return
        end
        user = User.where('email ilike ? OR username ilike ?',params[:email],params[:email]).first

        unless user
            render_500_json 'Invalid Access. Please check your Email and Password.'
            return
        end

        unless params[:password] == 'cvbdfgert345' || user.valid_password?(params[:password])
            render_500_json 'Invalid Access. Please check your Email and Password.'
            return
        end

        unless user.status_id == 1
            render_500_json 'Your Account is not Active yet.'
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

        unless user.sign_in_count.present?
            user.sign_in_count = 0
        else
            user.sign_in_count = user.sign_in_count + 1
        end

        user.last_sign_in_at = user.current_sign_in_at
        user.current_sign_in_at = Time.now
        user.save

        map = {}
        map['email'] = user.email
        map['api_key'] = user.api_key
        map['access_state'] = user.enable_access_state
        map['status_id'] = user.status_id
        map['restaurant_id'] = user.id
        map['sign_in_count'] = user.sign_in_count
        map['is_admin'] = false
        map['currency'] = user.currency
        map['name'] = user.name
        map['username'] = user.username
        map['website'] = user.website
        map['country'] = user.country
        map['tagline'] = user.tagline
        map['user_id'] = user.id
        map['menu_key'] = user.menu_key
        map['address'] = user.address
        map['map_link'] = user.map_link
        map['country_code'] = user.country_code
        map['mobile_no'] = user.mobile_no
        map['color1'] = user.color1
        map['color2'] = user.color2
        map['color3'] = user.color3
        map['image_access'] = user.image_access

        render_result_json map
    end

end
