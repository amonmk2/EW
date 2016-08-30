#! ruby
# coding: utf-8

require 'erb'

module ReportBuilder 

	class Index_rep

		attr_accessor :template_html, :index

	  def initialize
	    @template_html = "layout/index_html.erb"
	    @index = Hash.new {|hash, key| hash[key] = ""}
	  end

	  def to_index
		  @page = ERB.new(File.read(@template_html),nil,'-').result(binding)
	  end

	  def get_binding
	    call_binding { @page }
	  end

	  private

	  def call_binding
	    binding
	  end

	end

end
