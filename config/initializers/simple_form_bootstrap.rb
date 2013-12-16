# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  config.error_notification_class = 'alert alert-error'
  config.label_class = 'control-label'

  config.wrappers :bootstrap, :tag => 'div', :class => 'form-group', :error_class => 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.use :input, :wrap_with => { :tag => 'div', :class => 'controls col-xs-4 col-sm-4 col-md-4 col-lg-4' }
    b.use :error, :wrap_with => { :tag => 'span', :class => 'help-block' }
    b.use :hint,  :wrap_with => { :tag => 'p', :class => 'help-block' }
  end

  config.wrappers :prepend, tag: 'div', class: "form-group", error_class: 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper tag: 'div', class: 'controls' do |input|
      input.wrapper tag: 'div', class: 'input-prepend' do |prepend|
        prepend.use :input
      end
      input.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
      input.use :error, wrap_with: { tag: 'span', class: 'help-inline' }
    end
  end

  config.wrappers :append, tag: 'div', class: "form-group", error_class: 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper tag: 'div', class: 'controls' do |input|
      input.wrapper tag: 'div', class: 'input-append' do |append|
        append.use :input
      end
      input.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
      input.use :error, wrap_with: { tag: 'span', class: 'help-inline' }
    end
  end

  # Wrappers for forms and inputs using the Bootstrap toolkit.
  # Check the Bootstrap docs (http://getbootstrap.com/2.3.2/)
  # to learn about the different styles for forms and inputs,
  # buttons and other elements.
  config.form_class = "form-horizontal"
  config.label_class = "col-xs-2 col-sm-2 col-md-2 col-lg-2 control-label"
  #config.input_class = "form-control" #not yet supported
  config.default_wrapper = :bootstrap
end