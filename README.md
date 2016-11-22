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

## Usage

### Main File Header

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
