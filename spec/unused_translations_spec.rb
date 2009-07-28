require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)

describe UnusedTranslations do

  before(:all) do
    @dummy_source = "I18n.t('users.new.name') + t('.build') + t '.machin'"
  end

  it "should list application files" do
    list = UnusedTranslations::file_list
    list.should_not be_empty 
  end

  it "should build up keys listing" do
    File.stub!(:read).and_return(@dummy_source)
    keys = UnusedTranslations::parse_source_code('dummy_file')
    keys.should include('users.new.name')
    keys.should include('.build')
    keys.should include('.machin')
  end

  context "a translation" do
    it "should interpolate the key via file_name" do
      [["../../app/views/users/new.html.haml",  "users.new.title"],
       ["../../app/views/users/new.html.haml",  ".title"         ],
       ["../../app/views/users/_new.html.haml", "users.new.title"],
       ["../../app/views/users/_new.html.haml", ".title"         ]].each do |sample|
        t = UnusedTranslations::Translation.new(sample[0], sample[1])
        t.full_key.should == "users.new.title"
        t.to_hash.should == {"users" => {"new" => {"title" => nil}}}
       end
      t = UnusedTranslations::Translation.new('/views/big_stuff/under/_some_thing.html.haml', '.hey')
      t.full_key.should == "big_stuff.under.some_thing.hey"
      t.to_hash.should == {"big_stuff" => {"under" => {"some_thing" => {"hey" => nil}}}}
    end
  end

  context "translations" do
    it "should build up a great hash" do
      ts = UnusedTranslations::Translations.new
      ts.add('dummy_file', 'user.new.title')
      ts.add('dummy_file', 'user.new.desc')
      ts.add('dummy_file', 'user.edit.title')
      ts.add('dummy_file', 'proj.new.title')
      ts.translations.should == {"user" => {"new"  => {"title" => nil, "desc" => nil}, 
                                            "edit" => {"title" => nil               }, }, 
                                 "proj" => {"new"  => {"title" => nil               }  }  }
    end
  end

  it "should show the differences between locales file & used keys" do
    locales = {"user" => {"new"  => {"title" => "bla", "desc" => "bla"}, 
                          "edit" => {"title" => "bla"                 }, }, 
               "proj" => {"new"  => {"title" => "bla"                 }  }  }

    used =    {"user" => {"new"  => {"title" => nil                   },
                          "edit" => {"desc"  => nil                   }, },
               "proj" => {"new"  => {"title" => nil                   }  }  }

    diff =    {"user" => {"new"  => {                  "desc" => "bla"}, 
                          "edit" => {"title" => "bla"                 }  }  }

    UnusedTranslations.deep_diff(locales, used).should == diff
  end

end
