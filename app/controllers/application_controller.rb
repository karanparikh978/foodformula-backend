class ApplicationController < ActionController::Base

    skip_before_action :verify_authenticity_token

    def authenticate_admin
        is_valid_access = false

        admin = Admin.where(api_key: params[:api_key],status_id: CONTENT_STATUS_PUBLISHED).first
        if admin.present?
            is_valid_access = true
        end
        if is_valid_access
              @admin = admin
        else
            render_500_json "Invalid Access"
            return
        end
    end

    def authenticate_user
        is_valid_access = false

        user = User.where(api_key: params[:api_key],status_id: CONTENT_STATUS_PUBLISHED).first
        if user.present?
            is_valid_access = true
        end
        if is_valid_access
            @user = user
        else
            render_500_json "Invalid Access"
            return
        end
    end

    def has_sufficient_params(params_list)
        params_list.each do |param|
            unless params[param].present?
                render_500_json "#{param.gsub('_',' ')} is mandatory".camelize
                return false
            end
        end
        return true
    end


    def render_result_json object
        response = {status: 'success', contents: object}
        render json: response
    end
    
    def render_success_json object
        response = get_success_json(object)
        render json: response
    end
    
    def get_success_json(object)
        response = {status: 'success', message: object}
    end
    
    def render_error_json message
        response = {status: 'error', message: message}
        render json: response
    end
    
    def render_500_json message
        response = {status: 'error', message: message}
        render json: response, status: 500
    end
  

end
