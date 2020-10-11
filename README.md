# Dict to dataclass

Utils for mapping dataclass fields to dictionary keys, making it possible to create an instance of a dataclass from a dictionary.

```python
# Declare dataclass fields with `field_from_dict`
@dataclass
class MyDataclass(DataclassFromDict):
    my_string: str = field_from_dict()
    my_int: int = field_from_dict()
    my_date: datetime = field_from_dict()


# Create a dataclass instance using the `from_dict` constructor
origin_dict = {
  "my_string": "Hello",
  "my_int": 123,
  "my_date": "2020-10-11T13:21:23.396748",
}

dataclass_instance = MyDataclass.from_dict(origin_dict)

# Now, our dataclass instance has the values from the dictionary
>>> dataclass_instance.my_string
"Hello"

>>> dataclass_instance.my_int
123

>>> dataclass_instance.my_date
datetime.datetime(2020, 10, 11, 13, 21, 23, 396748)
```

## Nested data classes

Nested dictionaries can be represented by nested dataclasses.

```python
@dataclass
class Child(DataclassFromDict):
    my_field: str = field_from_dict()


@dataclass
class Parent(DataclassFromDict):
    child_field: Child = field_from_dict()


origin_dict = {
  "child_field": {
      "my_field": "Hello"
  }
}

dataclass_instance = Parent.from_dict(origin_dict)

>>> dataclass_instance.child_field.my_field
"Hello"
```

## Finding dictionary values

You may have noticed that we don't need to specify where to look in the dictionary for field values. That's because by default, the name given to the field in the data class is used. It even works if the key in the dictionary is in camelCase:

```python
@dataclass
class MyDataclass(DataclassFromDict):
    my_field: str = field_from_dict()


origin_dict = {
    "myField": "field value"
}

dataclass_instance = MyDataclass.from_dict(origin_dict)

>>> dataclass_instance.my_field
"field value"
```

It's probably quite common that your dataclass fields have the same names as the dictionary keys they map to but in case they don't, you can pass the dictionary key as the first argument to `field_from_dict`:

```python
@dataclass
class MyDataclass(DataclassFromDict):
    name_in_dataclass: str = field_from_dict("nameInDictionary")

origin_dict = {
    "nameInDictionary": "field value"
}

dataclass_instance = MyDataclass.from_dict(origin_dict)

>>> dataclass_instance.name_in_dataclass
"field value"
```

## Lists

List types are handled but the type of the list's items must be specified in the dataclass field type so that we know how to convert them.

```python
@dataclass
class MyDataclass(DataclassFromDict):
    my_list_field: List[str] = field_from_dict()

origin_dict = {
    "my_list_field": ["First", "Second", "Third"]
}

dataclass_instance = MyDataclass.from_dict(origin_dict)

>>> dataclass_instance.my_list_field
["First", "Second", "Third"]
```

If we were to use `typing.List` or `list` as the field type, an error would be raised when converting the dictionary (there's more info on errors later).

```python
@dataclass
class MyDataclass(DataclassFromDict):
    name_in_dataclass: List = field_from_dict("nameInDictionary")

origin_dict = {
    "my_list_field": ["First", "Second", "Third"]
}

# Here, a `NonSpecificListFieldError` is raised
dataclass_instance = MyDataclass.from_dict(origin_dict)
```

## Custom value converters

By default, `str`, `int`, `bool`, `float` types can be taken from dictionaries without conversion.

Dataclass fields of type `datetime` can be converted from

- Strings (handled by `dateutil`)
- Python-style timestamps of type `float`, e.g. `1602436272.681808`
- Javascript-style timestamps of type `int`, e.g. `1602436323268`

If you need to convert a dictionary value that isn't covered by the defaults, you can pass in a converter function to `field_from_dict`:

```python
def yes_no_to_bool(yes_no: str) -> bool:
    return yes_no == "yes"


@dataclass
class MyDataclass(DataclassFromDict):
    is_yes: bool = field_from_dict(converter=yes_no_to_bool)

origin_dict = {
    "is_yes": "yes"
}

dataclass_instance = MyDataclass.from_dict(origin_dict)

>>> dataclass_instance.is_yes
True
```
