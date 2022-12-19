class LanguageController < ApplicationController

    before_action :authenticate_admin

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

    def create_user_language
        unless has_sufficient_params(['user_id','language_id'])
            return
        end
        master_language = MastersLanguage.where(id: params[:language_id]).first
        unless master_language
            render_500_json 'Master Language not present.'
            return
        end
        user_language = UserLanguage.where(user_id: params[:user_id],language_id: params[:language_id]).first
        if user_language.present?
            render_500_json 'This user language already present.'
            return
        end
        user_language = UserLanguage.new
        user_language.user_id = params[:user_id]
        user_language.language_id = params[:language_id]
        user_language.save
        obj = {}
        obj['id'] = user_language.id
        obj['name'] = user_language.master.name rescue nil
        render_result_json obj
    end

    def remove_user_language
        unless has_sufficient_params(['user_language_id'])
            return
        end
        user_language = UserLanguage.where(id: params[:user_language_id]).first
        unless user_language
            render_500_json 'User Language not found.'
            return
        end
        user_language.destroy
        render_success_json 'User Language removed.'
    end

end
