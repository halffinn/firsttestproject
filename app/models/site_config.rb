class SiteConfig < ActiveRecord::Base
  def self.instance
    SiteConfig.first || SiteConfig.new
  end

  def self.mail_sysadmins
    %w(fer@heypal.com nico@heypal.com).join(', ')
  end

  def self.method_missing(name, *args)
    if self.instance.attributes.has_key?(name.to_s)
      val = self.instance.attributes[name.to_s]
      if val.present?
        val
      else
        # Backward compatibility with config constants
        name.to_s.upcase.constantize
      end
    else
      super
    end
  end
end
