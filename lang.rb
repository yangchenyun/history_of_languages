Lang = Struct.new(:name,
                  :link,
                  :paradigm,
                  :appear_in,
                  :designer,
                  :developer,
                  :influenced_by,
                  :influenced) do
  def initialize
    super
    self.influenced = []
    self.influenced_by = []
  end
end