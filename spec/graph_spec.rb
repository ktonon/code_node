require 'code_node/spec_helpers'

describe 'code_node' do

  include Cog::SpecHelpers
  
  before :all do
    @cog = Cog::SpecHelpers::Runner.new 'cog'
  end

  describe 'activerecord error graph' do
    before :all do 
      use_fixture :errors
      @cog.run(:generator, :run).should make(generated_file('graph.dot'))
      @dot = CodeNode::SpecHelpers::DotFile.new :graph
    end
    
    it 'should exist' do
      @dot.should exist
    end
  
    it 'should have ActiveRecord as a root module' do
      @dot.should have_module('ActiveRecord')
    end
    
    it 'should have ActiveRecord::ActiveRecordError but not ActiveRecordError' do
      @dot.should have_class('ActiveRecord::ActiveRecordError')
      @dot.should_not have_node('ActiveRecordError')
    end
  end
  
  describe 'activerecord graph with exclusion' do
    before :all do 
      use_fixture :activerecord
      @cog.run(:generator, :run).should make(generated_file('graph.dot'))
      @dot = CodeNode::SpecHelpers::DotFile.new :graph
    end
    
    it 'should exist' do
      @dot.should exist
    end
  
    it 'should have ActiveRecord as a root module' do
      @dot.should have_module('ActiveRecord')
    end
    
    it 'should not have ActiveRecord::ActiveRecordError or ActiveRecordError' do
      @dot.should_not have_node('ActiveRecord::ActiveRecordError')
      @dot.should_not have_node('ActiveRecordError')
    end
    
    it 'should not have ActiveRecordError subclasses' do
      @dot.should_not have_node('ActiveRecord::HasOneThroughCantAssociateThroughCollection')
      @dot.should_not have_node('ActiveRecord::HasManyThroughSourceAssociationNotFoundError')
      @dot.should_not have_node('ActiveRecord::Transactions::TransactionError')
      @dot.should_not have_node('ActiveRecord::ConnectionTimeoutError')
    end
    
    it 'should not have any ClassMethods modules' do
      @dot.should_not have_match(/ClassMethods/)
    end

    it 'should not have any reference to Autoload or Concern' do
      @dot.should_not have_match(/ActiveSupport::Autoload/)
      @dot.should_not have_match(/ActiveSupport::Concern/)
    end
    
    it 'should not have exclude islands which are created by other exclusions' do
      @dot.should have_module('ActiveRecord::ConnectionAdapters')
      @dot.should_not have_node('ActiveRecord::ConnectionAdapters::ConnectionManagement')
      @dot.should_not have_node('ActiveRecord::ConnectionAdapters::ConnectionManagement::Proxy')
    end
    
    it 'should not have SingularAssociation at the top level' do
      @dot.should_not have_node('SingularAssociation')
    end
    
    it 'should have ActiveRecord::AttributeMethods but not AttributeMethods' do
      @dot.should have_module('ActiveRecord::AttributeMethods')
      @dot.should_not have_node('AttributeMethods')
    end
    
    it 'should have a link from Dirty to Write within AttributeMethods scope' do
      @dot.should_not have_inclusion('ActiveRecord::AttributeMethods::Dirty', 'AttributeMethods::Write')
      @dot.should have_inclusion('ActiveRecord::AttributeMethods::Dirty', 'ActiveRecord::AttributeMethods::Write')
    end
    
    it 'should have ActiveRecord::Locking::Optimistic but not Locking::Optimistic' do
      @dot.should have_module('ActiveRecord::Locking::Optimistic')
      @dot.should have_module('ActiveRecord::Locking::Pessimistic')
      @dot.should_not have_node('Locking::Optimistic')
      @dot.should_not have_node('Locking::Pessimistic')
    end
  end
end
