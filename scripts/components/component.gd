@icon("res://icons/Component.svg")
class_name Component
extends Node
## Base class for all components.
##
## [b]Components[/b] are nodes that extend their parent nodes with additional
## functionality or interactability with other nodes. Components always will be
## connected with the parent, from its creation to its deletion. They are not
## designed to switch parents while in the scene tree.
## [br][br]
## An example of a component that prints the name of its parent to the console:
## [codeblock]
## class_name PrintNameComponent
## extends Component
## 
## func _ready() -> void:
##     print(owner.name)
## [/codeblock]
## The [Component] node by default doesn't come with any properties or methods.
