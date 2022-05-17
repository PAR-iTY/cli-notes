# JavaBeans

> from: https://stackoverflow.com/a/3295517

A JavaBean is just a standard - a convention lots of libraries depend on

- All properties are private (use getters/setters)
- A public no-argument constructor
- Implements `java.io.Serializable`

there is no syntactic difference between a JavaBean and another class - a class is a JavaBean if it follows the standards.

With respect to Serializable, from the API documentation:

> "Serializability of a class is enabled by the class implementing the java.io.Serializable interface. Classes that do not implement this interface will not have any of their state serialized or deserialized. All subtypes of a serializable class are themselves serializable. The serialization interface has no methods or fields and serves only to identify the semantics of being serializable."

Serializable objects can be written to streams, and hence files, object databases, anything really.

There is a term for it, because the standard allows libraries to programmatically do things with class instances you define in a predefined way. For example, if a library wants to stream any object you pass into it, it knows it can because your object is serializable (assuming the library requires your objects be proper JavaBeans).