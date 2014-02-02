Lang = Struct.new(:name,
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