#! ruby
# coding: utf-8

require 'erb'
require "CSV"

class EW 

	def initialize (rule_csv)
		@hash = Hash.new { |h,k| h[k] = Hash.new { |h,k| h[k] = [] } }

		#read rule
		@rule = Hash.new { |h,k| h[k] = {} }
		CSV.foreach(rule_csv){ |row|
			stage = row[0]
 			code = row[1]
 			msg = row[3]
  			@rule[stage][code] = msg
		}

		@stage_list = ["stage1","stage2","stage3"]

	end	

	def read (txt)
		state = ""

		File.foreach(txt) do |line|

			# state machine
			if line =~ /^# stage1/
				state = 0
			elsif line =~ /^# stage2/
				state = 1
			elsif line =~ /^# stage3/
				state = 2
			else
				state = state
			end

			# get msg
			if line =~ /(ERROR\d+|WARNING\d+) (.+)$/
				code = $1
				msg = $2
				# stage hash
				@hash["#{@stage_list[state]}"][code].push(msg)
			end
		end

	end

	def table_html(stage)
		ERB.new(File.read("list_html.erb"),nil,'-').result(binding)
	end

	def table_html_page
		@page = ""
		@stage_list.each { |stage| 
			@page << self.table_html(stage) 
		}
		@page
	end

    def get_binding
      call_binding { @page }
    end

    private

    def call_binding
      binding
    end

end

class Report_builder
	def initialize(template)
    	@template = ERB.new(File.read(template), nil, "-")
  	end

  	def build(rule,log)
   	 	context = EW.new(rule)
   	 	context.read(log)
   	 	context.table_html_page
   	 	@template.run(context.get_binding)
  	end

end 

#ew = EW.new("rule.csv")
#ew.read("testdata.txt")


#puts ew.table_html("stage1")
#puts ew.table_html_page

rep = Report_builder.new("layout.erb")
puts rep.build("rule.csv","testdata.txt")

__END__
