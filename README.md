# Shapefile Reader

A Ruby library that can be used to read ESRI Shapefiles.

## What is a Shapefile?

A shapefile stores nontopological geometry and attribute information for the spatial
features in a data set. The geometry for a feature is stored as a shape comprising a set of
vector coordinates.

Because shapefiles do not have the processing overhead of a topological data structure,
they have advantages over other data sources such as faster drawing speed and edit
ability. Shapefiles handle single features that overlap or that are noncontiguous. They
also typically require less disk space and are easier to read and write.

Shapefiles can support point, line, and area features. Area features are represented as
closed loop, double-digitized polygons. Attributes are held in a dBASE® format file.
Each attribute record has a one-to-one relationship with the associated shape record.

## Main File Header

| Method Name | Description | Example Value |
| --- | --- | --- |
| file_code | File code (always hex value 0x0000270a)	| 9994 |
| file_length | Size of the file, including the header, in bytes | 49915112 |
| version | Version of the file | 1000 |
| shape_type | The type of shape contained in the file. All shapes will either be the specified shape or null. You can see the list below to see what values map to what shapes. | 1 |
| x_min | Minimum x value of all shapes | -179.14734 |
| x_max | Maximum x value of all shapes | 179.77848 |
| y_min | Minimum y value of all shapes | 71.38921 |
| y_max | Minimum y value of all shapes | 18.91112 |
| z_min | Minumum z value of all shapes (Optional) | 0.0 |
| z_max | Maximum z value of all shapes (Optional) | 0.0 |
| m_min | Minimum measured value (Optional) | 0.0 |
| m_max | Maximum measure value (Optional) | 0.0 |

### Usage

```
reader = Shapefile::Reader.new(path_to_shapefile)
reader.main_file_header
```

### Read Records

```
reader = Shapefile::Reader.new(path_to_shapefile)
reader.each_record do |header, shape|
  # Your code here...
end
```
