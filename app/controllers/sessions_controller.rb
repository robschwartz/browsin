class SessionsController < Devise::SessionsController
  respond_to :json

  def create
    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    sign_in_and_redirect(resource_name, resource)
  end

  def failure
    return render :json => {:success => false, :errors => ["Login failed."]}
  end

  private

  def sign_in_and_redirect(resource_or_scope, resource=nil)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource
    return render :json => {:success => true, :user => current_user.email}
  end

  def respond_to_on_destroy
    respond_to do |format|
      format.all { head :no_content }
      format.any(*navigational_formats) { return render :json=> {:success => true} }
    end
  end

end
