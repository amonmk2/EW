#! ruby

require "CSV"

class EW 

	def initialize (rule_csv)
		@hash = Hash.new { |h,k| h[k] = Hash.new { |h,k| h[k] = [] } }

		#read rule
		@rule = Hash.new { |h,k| h[k] = {} }
		CSV.foreach(rule_csv){ |row|
			stage = row[0]
 			code = row[1]
  			@rule[stage][code] = 1
		}

	end	

	def read (txt)
		state = ""

		File.foreach(txt) do |line|

			# state machine
			if line =~ /^# stage1/
				state = "001"
			elsif line =~ /^# stage2/
				state = "010"
			elsif line =~ /^# stage3/
				state = "100"
			else
				state = state
			end

			# get msg
			if line =~ /(ERROR\d+|WARNING\d+) (.+)$/
				code = $1
				msg = $2

				case state
				when "001" then 
					# stage1 hash
					@hash["stage1"][code].push(msg)
				when "010" then
					# stage2 hash
					@hash["stage2"][code].push(msg) 
				when "100" then
					# stage3 hash
					@hash["stage3"][code].push(msg) 
				else
				end
			end
		end

	end

	def put(stage)
		@hash[stage].each_key { |code|
			@hash[stage][code].each_with_index { |msg,i|
				if (@rule[stage][code]) 
					puts "OK #{code} : (#{i+1}) #{msg}"
				else
					puts "NG #{code} : (#{i+1}) #{msg}"
				end
			}
		}
	end

	def put_all
		["stage1","stage2","stage3"].each { |stage| self.put(stage) }
	end

end


ew = EW.new("rule.csv")
ew.read("testdata.txt")
puts "stage1"
ew.put("stage1")
puts "stage2"
ew.put("stage2")
puts "stage3"
ew.put("stage3")

puts "ALL"
ew.put_all
