class EntityController < ApplicationController

    before_action :authenticate_admin

    def add_or_update_entity

        if params[:id].present?
            entity = MastersEntity.where(id: params[:id]).first
            unless entity
                render_500_json 'Entity not found.'
                return
            end
            entity.name = params[:name] if params[:name].present?
            entity.status_id = params[:status_id] if params[:status_id].present?
            entity.save

            render_success_json 'Entity updated.'
        else
            entity = MastersEntity.where('trim(name) ilike (?)',params[:name].strip).first
            if entity.present?
                render_500_json 'Entity with same name already present.'
                return
            end
            entity = MastersEntity.new
            entity.name = params[:name]
            entity.status_id = params[:status_id].present? ? params[:status_id] : CONTENT_STATUS_PUBLISHED
            entity.save

            render_success_json 'Entity added.'
        end
    end

    def get_all_masters_entities
        masters_entities = MastersEntity.all
        render_result_json masters_entities
    end

    def get_entity_by_id
        unless has_sufficient_params(['id'])
            return
        end
        entity = MastersEntity.where(id: params[:id]).first
        unless entity
            render_500_json 'Entity not found.'
            return
        end
        render_result_json entity
    end

    def create_user_entity
        unless has_sufficient_params(['user_id','entity_id'])
            return
        end
        master_entity = MastersEntity.where(id: params[:entity_id]).first
        unless master_entity
            render_500_json 'Master Entity not present.'
            return
        end
        user_entity = UserEntity.where(user_id: params[:user_id],entity_id: params[:entity_id]).first
        if user_entity.present?
            render_500_json 'This user entity already present.'
            return
        end
        user_entity = UserEntity.new
        user_entity.user_id = params[:user_id]
        user_entity.entity_id = params[:entity_id]
        user_entity.save
        obj = {}
        obj['id'] = user_entity.id
        obj['name'] = user_entity.master.name rescue nil
        render_result_json obj
    end

    def remove_user_entity
        unless has_sufficient_params(['user_entity_id'])
            return
        end
        user_entity = UserEntity.where(id: params[:user_entity_id]).first
        unless user_entity
            render_500_json 'User Entity not found.'
            return
        end
        user_entity.destroy
        render_success_json 'User Entity removed.'
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
            render_500_json 'User Entity not found.'
            return
        end
        user_language.destroy
        render_success_json 'User Entity removed.'
    end

end
