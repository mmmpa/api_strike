module SlashTrimmer
  refine String do
    def trim_slash
      self.gsub(/\/+$/, '')
    end


    def add_slash
      '/' + self.gsub(/^\/+/, '')
    end


    def add_and_trim_slash
      self.add_slash.trim_slash
    end
  end
end
