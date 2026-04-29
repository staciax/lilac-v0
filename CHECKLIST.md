# CHECKLIST

This checklist is maintained alongside development to track topic coverage.

Some items may be incomplete, partially implemented, or not yet reviewed.

**Structures and Classes**
- [x] Comparing Structures and Classes
  - [x] Definition Syntax
  - [x] Structure and Class Instances
  - [x] Accessing Properties
  - [x] Memberwise Initializers for Structure Types
- [x] Structures and Enumerations Are Value Types
- [ ] Classes Are Reference Types
  - [ ] Identity Operators
  - [ ] Pointers

**Properties**
- [x] Stored Properties
  - [x] Stored Properties of Constant Structure Instances
  - [x] Lazy Stored Properties
  - [ ] Stored Properties and Instance Variables
- [x] Computed Properties
  - [ ] Shorthand Setter Declaration
  - [ ] Shorthand Getter Declaration
  - [x] Read-Only Computed Properties
- [ ] Property Observers
- [ ] Property Wrappers
  - [ ] Setting Initial Values for Wrapped Properties
  - [ ] Projecting a Value From a Property Wrapper
- [ ] Global and Local Variables
- [x] Type Properties
  - [x] Type Property Syntax
  - [ ] Querying and Setting Type Properties

**Methods**
- [x] Instance Methods
  - [x] The self Property
  - [ ] Modifying Value Types from Within Instance Methods
  - [ ] Assigning to self Within a Mutating Method
- [ ] Type Methods

**Subscripts**
- [x] Subscript Syntax
- [x] Subscript Usage
- [x] Subscript Options
- [ ] Type Subscripts

**Inheritance**
- [x] Defining a Base Class
- [x] Subclassing
- [x] Overriding
  - [ ] Accessing Superclass Methods, Properties, and Subscripts
  - [x] Overriding Methods
  - [ ] Overriding Properties
- [x] Preventing Overrides

**Initialization**
- [x] Setting Initial Values for Stored Properties
  - [x] Initializers
  - [x] Default Property Values
- [x] Customizing Initialization
  - [x] Initialization Parameters
  - [x] Parameter Names and Argument Labels
  - [x] Initializer Parameters Without Argument Labels
  - [x] Optional Property Types
  - [x] Assigning Constant Properties During Initialization
- [x] Default Initializers
  - [x] Memberwise Initializers for Structure Types
- [x] Initializer Delegation for Value Types
- [x] Class Inheritance and Initialization
  - [x] Designated Initializers and Convenience Initializers
  - [x] Syntax for Designated and Convenience Initializers
  - [x] Initializer Delegation for Class Types
  - [x] Two-Phase Initialization
  - [ ] Initializer Inheritance and Overriding
  - [ ] Automatic Initializer Inheritance
  <!-- - [ ] Designated and Convenience Initializers in Action -->
- [ ] Failable Initializers
  - [ ] Failable Initializers for Enumerations
  - [ ] Failable Initializers for Enumerations with Raw Values
  - [ ] Propagation of Initialization Failure
  - [ ] Overriding a Failable Initializer
  - [ ] The init! Failable Initializer
- [ ] Required Initializers
- [x] Setting a Default Property Value with a Closure or Function

**Deinitialization**
<!-- - [x] How Deinitialization Works -->
- [x] Deinitializers in Action

**Optional Chaining**
- [x] Optional Chaining as an Alternative to Forced Unwrapping
- [x] Defining Model Classes for Optional Chaining
- [x] Accessing Properties Through Optional Chaining
- [ ] Calling Methods Through Optional Chaining
- [ ] Accessing Subscripts Through Optional Chaining
  - [x] Accessing Subscripts of Optional Type
- [ ] Linking Multiple Levels of Chaining
- [ ] Chaining on Methods with Optional Return Values

**Error Handling**
- [x] Representing and Throwing Errors
- [x] Handling Errors
  - [x] Propagating Errors Using Throwing Functions
  - [x] Handling Errors Using Do-Catch
  - [x] Converting Errors to Optional Values
  - [x] Disabling Error Propagation
- [x] Specifying the Error Type
- [x] Specifying Cleanup Actions (defer)

**Type Casting**
- [x] Defining a Class Hierarchy for Type Casting
- [ ] Checking Type
- [x] Downcasting
- [ ] Type Casting for Any and AnyObject

**Nested Types**
- [x] Nested Types in Action
- [ ] Referring to Nested Types
