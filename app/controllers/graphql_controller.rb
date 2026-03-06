# frozen_string_literal: true

class GraphqlController < ApplicationController
  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]

    raw_token = request.headers["Authorization"]&.delete_prefix("Bearer ")
    current_user = resolve_current_user(raw_token)

    if raw_token.present? && current_user.nil?
      return render json: { errors: [ { message: "Unauthorized" } ] }, status: :unauthorized
    end

    context = { current_user: current_user, request: request }
    result = ArkheionSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue StandardError => e
    raise e unless Rails.env.development?

    handle_error_in_development(e)
  end

  private

  def resolve_current_user(token)
    return nil if token.blank?

    Auth::JwtService.valid_access_token?(token) || nil
  rescue StandardError
    nil
  end

  def prepare_variables(variables_param)
    case variables_param
    when String
      variables_param.present? ? JSON.parse(variables_param) || {} : {}
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def handle_error_in_development(err)
    logger.error err.message
    logger.error err.backtrace.join("\n")

    render json: { errors: [{ message: err.message, backtrace: err.backtrace }], data: {} }, status: 500
  end
end
