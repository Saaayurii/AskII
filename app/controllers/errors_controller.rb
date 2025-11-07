class ErrorsController < ActionController::Base
  include SwitchLocale

  layout 'error'
  around_action :switch_locale

  def not_found
    @error_code = 404
    @error_title = I18n.t('errors.not_found.title')
    @error_description = I18n.t('errors.not_found.description')
    render :show, status: :not_found
  end

  def unprocessable_entity
    @error_code = 422
    @error_title = I18n.t('errors.unprocessable_entity.title')
    @error_description = I18n.t('errors.unprocessable_entity.description')
    render :show, status: :unprocessable_entity
  end

  def internal_server_error
    @error_code = 500
    @error_title = I18n.t('errors.internal_server_error.title')
    @error_description = I18n.t('errors.internal_server_error.description')
    render :show, status: :internal_server_error
  end

  def forbidden
    @error_code = 403
    @error_title = I18n.t('errors.forbidden.title')
    @error_description = I18n.t('errors.forbidden.description')
    render :show, status: :forbidden
  end
end
