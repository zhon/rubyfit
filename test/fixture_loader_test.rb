# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'test/unit'
require 'flexmock/test_unit'

# Make the test run location independent
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'fit/fixture_loader'

require 'fit/import_fixture'
require 'eg/nested/bob_the_builder_fixture'
require 'eg/music/browser'

class A; end
class AFixture < Fit::Fixture; end

module Ex; 
  class MyFixture < Fit::Fixture
    class Inner < Fit::Fixture; end
  end
end 

module Fit
  class FixtureLoaderTest < Test::Unit::TestCase

    def setup
      @loader = flexmock(FixtureLoader.new)
      @loader.should_receive(:require)
    end
    def test_you_can_load_a_fixture
      assert_instance_of(Ex::MyFixture, @loader.load('Ex.MyFixture'))
    end
    def test_java_simple_fixture
      assert_instance_of(Ex::MyFixture, @loader.load('ex.MyFixture'))
    end
    def test_java_nested_fixture
      assert_instance_of(Ex::MyFixture::Inner, @loader.load('ex.MyFixture$Inner'))
    end
    def test_you_can_load_a_fixture_with_colons_rather_than_dots
      assert_instance_of(Ex::MyFixture, @loader.load('Ex::MyFixture'))
    end
    class LookImNotInTheRightPlace < Fixture
    end
    def test_you_can_load_any_fixture_already_loaded_regardless_of_path
      assert_instance_of(Fit::FixtureLoaderTest::LookImNotInTheRightPlace,
                         @loader.load('Fit.FixtureLoaderTest.LookImNotInTheRightPlace'))
    end
    def test_you_can_add_fixture_packages
      FixtureLoader.add_fixture_package('Eg::Music')
      assert_instance_of(Eg::Music::Browser, @loader.load('Browser'))
    end 
    def test_it_finds_fixtures_in_the_fit_module
      assert_instance_of(Fit::ImportFixture, @loader.load('ImportFixture'))
    end
    def test_it_adds_fixture_to_the_end_if_it_cant_find_the_class
      assert_instance_of(Fit::ImportFixture, @loader.load('Import'))
    end
    def test_it_camalizes_seperated_words
      FixtureLoader.add_fixture_package('Eg::Nested')
      assert_instance_of(Eg::Nested::BobTheBuilderFixture, @loader.load('bob the builder fixture'))
      assert_instance_of(Eg::Nested::BobTheBuilderFixture, @loader.load('bob the builder'))
    end
    def test_punctuation_seperates_words
      FixtureLoader.add_fixture_package('Eg::Nested')
      assert_instance_of(Eg::Nested::BobTheBuilderFixture, @loader.load('bob_the!-builder,fixture.'))
      assert_instance_of(Eg::Nested::BobTheBuilderFixture, @loader.load('bob_the!-builder.'))
    end
    def test_require_will_be_called_lots_of_times_for_a_missing_fixture
      l = flexmock(FixtureLoader.new)
      l.should_receive(:require).with('ex/na').raises(LoadError).once
      l.should_receive(:require).with('ex/na_fixture').raises(LoadError).once
      l.should_receive(:require).with('Ex/na').raises(LoadError).once
      l.should_receive(:require).with('Ex/na_fixture').raises(LoadError).once
      l.should_receive(:require).with('fit/ex/na').raises(LoadError).once
      l.should_receive(:require).with('fit/ex/na_fixture').raises(LoadError).once
      l.should_receive(:require).with('Fit/Ex/na').raises(LoadError).once
      l.should_receive(:require).with('Fit/Ex/na_fixture').raises(LoadError).once
      l.should_receive(:require).with('eg/nested/ex/na').raises(LoadError).once
      l.should_receive(:require).with('eg/nested/ex/na_fixture').raises(LoadError).once
      l.should_receive(:require).with('Eg/Nested/Ex/na').raises(LoadError).once
      l.should_receive(:require).with('Eg/Nested/Ex/na_fixture').raises(LoadError).once
      l.load('Ex.Na')
    rescue
    end
    def test_it_raises_when_it_cant_find_the_fixture
      @loader.load "NoSuchClass"
    rescue StandardError => e
      assert_equal("Fixture NoSuchClass not found.", e.to_s)
    end
    def test_it_only_loads_fixtures
      @loader.load "String"
      flunk("Should have thrown.")
    rescue StandardError => e
      assert_equal("String is not a fixture.", e.to_s)
    end
    def test_loading_fixture_when_fixture_name_is_same_as_another_class_name
      assert_instance_of(AFixture, @loader.load('A'))
    end
  end
end
