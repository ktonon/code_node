code_node
=========

Create `Class` and `Module` graphs for Ruby projects

**This project is still under development**

Get it
------

From a terminal

```bash
$ gem install code_node
```

Using it
--------

[Prepare your project](https://github.com/ktonon/cog#prepare-a-project) with `cog`

```bash
$ cog init
Created Cogfile
Created cog/generators
Created cog/templates
```

Edit `Cogfile` and change `project_source_path` to the root of your Ruby project.

Add `code_node` to the `COG_TOOLS` environment variable.

Create a `code_node` generator

```bash
$ cog --tool=code_node gen new my_graph
Created cog/generators/my_graph.rb
```

The generator will look like this

```ruby
require 'code_node'

# Makes a graph of the project_source_path
CodeNode.graph 'my_graph' do |g|

  g.ignore /ClassMethods$/
    
  g.ignore &:island?
  
end
```

Customize the graph generator. See [GraphDefiner](http://ktonon.github.com/code_node/CodeNode/DSL/GraphDefiner.html) for help.

Run that generator

```bash
$ cog gen run
1st pass: find nodes
2nd pass: find relations
Created lib/my_graph.dot
```

A [Graphviz](http://www.graphviz.org) dot file is created. [Get Graphviz](http://www.graphviz.org/Download.php)
and use the `dot` command line tool to turn your generated `my_graph.dot` file into an image.
For example

```bash
$ dot -T png -o lib/my_graph.png lib/my_graph.dot
```

Example
-------

Here is output of running +code_node+ on [activerecord](https://github.com/rails/rails/tree/master/activerecord/lib)

<img src="https://raw.github.com/ktonon/code_node/master/examples/activerecord.png" />