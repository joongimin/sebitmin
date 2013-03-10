module ProjectType
  include Application::Enum
  
  ProjectType.define :BOOK, 10
  ProjectType.define :POSTER, 20
  ProjectType.define :IDENTITY, 30
  ProjectType.define :INTERACTIVE, 40
end