#!/usr/bin/ruby

DATA_PATH=ENV['DATA_PATH']
SLOCC_OUTP = '/tmp/'

class Parser

  attr_accessor :sloc_report, :sloc_value

  def initialize
    @sloc_report = ''
    @sloc_value = ''
  end

  def list
     begin
     sources = Dir.entries(DATA_PATH)
     sources.delete('.')
     sources.delete('..')
    rescue SystemCallError
      puts "Diretório #{DATA_PATH} não encontrado"
    end
     sources
  end


  def run_sloccount sources
    sources.each do |source|
      if Dir.exists?(DATA_PATH + '/' + source.to_s)
        self.sloc_report = SLOCC_OUTP + '_' + source.to_s
        `sloccount #{DATA_PATH}/#{source} > #{self.sloc_report}`
        json(self.sloc_report)
      end
    end
  end

  def json file
    File.open(file).each_with_index do |line, index|

      if /SLOC/.match(line)
        sloc_parse(line, index)
      end

      if /Total Physical Source Lines of Code/.match(line)
        puts "Total Physical Source Lines of Code: #{line_value(line, "=", 1)}"
      end

      if /Totals grouped by language/.match(line)
        puts "Language: #{line_value((IO.readlines(self.sloc_report)[index + 1]), ":",  0)}"
      end

    end
  end

  private

  def sloc_parse(line, index)
    begin
      line_tokens = line.split(" ")
      if line_tokens[0] == 'SLOC' and line_tokens[1] == 'Directory'
         self.sloc_value =  line_value((IO.readlines(self.sloc_report)[index + 1]), 0)
         puts "SLOC VAlUE: #{self.sloc_value}"
      end
    rescue Exception
      puts 'SLOC value not found in this line'
    end
  end

  def line_value line, char=" ", pos
    line.split(char)[pos]
  end
end

a = Parser.new()
sources = a.list
a.run_sloccount(sources)
