class ColorGenerator
    WHITE = 'ffffff'
    #def self.generate(actual, target)
    #delta = actual - target
    #percent_delta = delta/target.to_f
    #if delta > 0
    #return green_shade(percent_delta)
    #else
    #return red_shade(percent_delta.abs)
    #end
    #end
    COLORS = ['E6550D', 'FDAE6B', 'FDD0A2','FFFFFF', 'A1D99B', '74C476','31A354']
    def self.generate(actual, target)
        delta = actual - target
        percent_delta = (delta/target.to_f).abs
        if delta > 0
            if percent_delta.in? 0..0.33
                return COLORS[4]
            elsif percent_delta.in? 0.33..0.66
                return COLORS[5]
            else
                return COLORS[6]
            end
        elsif delta == 0
            return COLORS[2]
        else
            if percent_delta.in? 0..0.33
                return COLORS[2]
            elsif percent_delta.in? 0.33..0.66
                return COLORS[1]
            else
                return COLORS[0]
            end
        end
    end

    def self.green_shade(change)
        rgb = WHITE.scan(/.{2}/)
        rgb[1] = rgb[1].to_i(16)
        rgb[0]  = rgb[2] = (rgb[1] - change * 255).to_i
        to_hex(rgb)
    end

    def self.red_shade(change)
        rgb = WHITE.scan(/.{2}/)
        rgb[0] = rgb[0].to_i(16)
        rgb[1]  = rgb[2] = (rgb[0] - change * 255).to_i
        to_hex(rgb)
    end

    def self.to_hex(int_list)
        int_list.map { |b| sprintf("%02X",b) }.join
    end
    def self.legend
        descrption = ["< -66%", "-66% to -33%", "-33% to 0%", "0%", "0% to 33%", "33% to 66%", "66% >"]
        legend = {}
        COLORS.each_with_index{|color,index| legend[descrption[index]] = '#' + color}
        legend
    end

end

