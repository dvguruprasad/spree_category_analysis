class ColorGenerator
    WHITE = 'ffffff'
    def self.generate(actual, target)
        delta = actual - target
        percent_delta = delta/target.to_f
        if delta > 0
            return green_shade(percent_delta)
        else
            return red_shade(percent_delta.abs)
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

end

