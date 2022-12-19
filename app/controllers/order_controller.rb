require 'sendgrid-ruby'
include SendGrid

class OrderController < ApplicationController

    def generate_order
        unless has_sufficient_params(['name','mobile_no','order_details','menu_key'])
            return
        end
        user = User.where(menu_key: params[:menu_key]).first
        order = Order.new
        order.name = params[:name]
        order.mobile_no = params[:mobile_no]
        order.email = params[:email]
        order.status_id = ORDER_NEW
        order.order_time = Time.now
        order.restaurant_id = user.id
        order.instruction = params[:instruction]
        order.address = params[:address]
        total_order_price = 0
        if order.save
            order_details = params[:order_details]
            order_details.each do |item|
                total_order_price = total_order_price + item['total_current_price']
                order_detail = OrderDetail.new
                order_detail.order_id = order.id
                order_detail.recipe_id = item['recipe_id']
                order_detail.quantity = item['quantity']
                order_detail.current_price = item['total_current_price']
                order_detail.save
            end
            order.update_attributes(total_price: total_order_price)

            # from = Email.new(email: 'foodformula928@gmail.com',name: 'Food Formula')
            # to = Email.new(email: user.email)
            # subject = 'New Order Generated'
            # content = Content.new(type: 'text/plain', value: 'New order generated. Please check on orders page.')
            # mail = Mail.new(from, subject, to, content)

            # sg = SendGrid::API.new(api_key: SENDGRID_API_KEY)
            # response = sg.client.mail._('send').post(request_body: mail.to_json)

            obj = {}
            obj['personalizations'] = []
            obj['personalizations'][0] = {}
            obj['personalizations'][0]['to'] = []
            obj['personalizations'][0]['to'][0] = {}
            obj['personalizations'][0]['to'][0]['email'] = user.email
            obj['personalizations'][0]['subject'] = "New Order Generated"
            obj['from'] = {}
            obj['from']['email'] = "foodformula928@gmail.com"
            obj['content'] = []
            obj['content'][0] = {}
            obj['content'][0]['type'] = "text/plain"
            obj['content'][0]['value'] = "New order generated. Please check on orders page."

            data = obj.to_json
            sg = SendGrid::API.new(api_key: SENDGRID_API_KEY)
            response = sg.client.mail._("send").post(request_body: data)

            render_success_json 'Order generated.'
        end
    end

    def get_order_details
        unless has_sufficient_params(['id'])
            return
        end
        order = Order.includes([order_details: :recipe]).where(id: params[:id]).first
        map = {}
        map['name'] = order.name
        map['mobile_no'] = order.mobile_no
        map['email'] = order.email
        map['status'] = order.status_id
        map['total_price'] = order.total_price
        map['instruction'] = order.instruction
        map['address'] = order.address
        recipes = []
        order_details = order.order_details
        if order_details.present?
            order_details.each do |order_detail|
                recipe_obj = {}
                recipe_obj['name'] = order_detail.recipe.name
                recipe_obj['quantity'] = order_detail.quantity
                recipe_obj['price'] = order_detail.current_price
                recipes << recipe_obj
            end
        end
        map['recipes'] = recipes
        render_result_json map
    end

    def get_restaurant_orders
        unless has_sufficient_params(['restaurant_id'])
            return
        end
        orders = Order.where(restaurant_id: params[:restaurant_id]).order('created_at DESC')
        render_result_json orders
    end

    def update_order
        unless has_sufficient_params(['id','status_id'])
            return
        end
        order = Order.where(id: params[:id]).first
        order.status_id = params[:status_id]
        order.save
        render_success_json 'Order status updated.'
    end

    def get_end_user_orders
        unless params[:email].present? || params[:mobile_no].present?
            render_500_json "Email or Mobile No is Required."
        end
        if params[:email].present?
            orders = Order.where('trim(email) ilike ?',params[:email].strip).order('created_at DESC').limit(10)
        else
            orders = Order.includes([order_details: :recipe]).where(mobile_no: params[:mobile_no]).order('created_at DESC').limit(10)
        end
        map = []
        if orders.present?
            orders.each do |order|
                obj = {}
                obj['total_price'] = order.total_price
                obj['status'] = ORDER_STATUSES[order.status_id]
                obj['order_created_at'] = order.created_at
                recipes = []
                order_details = order.order_details
                if order_details.present?
                    order_details.each do |order_detail|
                        recipe_obj = {}
                        recipe_obj['name'] = order_detail.recipe.name
                        recipe_obj['quantity'] = order_detail.quantity
                        recipe_obj['price'] = order_detail.current_price
                        recipes << recipe_obj
                    end
                end
                obj['recipes'] = recipes
                map << obj
            end
        end
        render_result_json map
    end

end
