class Fixnum
  def to_human_readable
    n = self
    if n < 1024
      return "#{n} B"
    elsif n >= 1024 and n < 1024*1024
      return "%.1f KB" % (n.to_f / 1024)
    else
      return "%.1f MB" % (n.to_f / (1024*1024))
    end
  end
end
