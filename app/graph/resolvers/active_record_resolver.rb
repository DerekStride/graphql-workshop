module ActiveRecordResolver
  def self.call(_, args, _)
    GlobalID::Locator.locate(args[:id])
  end
end
