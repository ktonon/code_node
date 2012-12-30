code_node
=========

[![Build Status](https://secure.travis-ci.org/ktonon/code_node.png?branch=master)](https://travis-ci.org/ktonon/code_node)
[![Dependency Status](https://gemnasium.com/ktonon/code_node.png)](https://gemnasium.com/ktonon/code_node)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/ktonon/code_node)

Create graphs of the classes and modules in a Ruby project

Get it
------

Install the [gem][] from a terminal

```bash
$ gem install code_node
```

Use it
------

code_node is a [cog][] plugin. To use it, you'll need to:

* run `cog init` from a terminal in the root of your project
* edit the `Cogfile` and change `project_path` to the root of your Ruby source.

Now that your project is ready, create a `code_node` graph generator like this

```bash
$ cog gen new -p code_node my_graph
Created cog/generators/my_graph.rb
```

The generator will look something like this

```ruby
CodeNode.graph 'my_graph' do |g|

  # Ignore nodes with no relations to other nodes
  g.ignore &:island?

  # Uncomment and change the value to ignore a specific node
  # g.ignore 'Foo::Bar::Car'
  
  # Uncomment to ignore nodes named ClassMethods
  # g.ignore /::ClassMethods$/

  # Uncomment and change the value to ignore all nodes descending
  # from a specific node
  # g.ignore {|node| node.inherits_from? 'Foo::Bar::Car'}
  
  # Apply styles common to all classes
  g.style :shape => 'ellipse', &:class?

  # Apply styles common to all nodes
  g.style :shape => 'box', &:module?
end
```

Customize the graph generator (see [GraphDefiner](http://ktonon.github.com/code_node/CodeNode/DSL/GraphDefiner.html) for help) and then run that generator

```bash
$ cog gen
1st pass: find nodes
2nd pass: find relations
Pruning nodes
Created lib/my_graph.dot
```

A [Graphviz][] dot file is created. [Get Graphviz][] and use the `dot` command
line tool to turn your generated `my_graph.dot` file into an image. For example

```bash
$ dot -T png -o lib/my_graph.png lib/my_graph.dot
```

[cog]:https://github.com/ktonon/cog
[gem]:https://rubygems.org/gems/code_node
[Graphviz]:http://www.graphviz.org
[Get Graphviz]:http://www.graphviz.org/Download.php
