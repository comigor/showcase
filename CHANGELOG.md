# CHANGELOG

## 0.5.1
- Consider named parameters when querying for required.

## 0.5.0
- Use forDesignTime when default constructor has required parameters.

In order to be showcased, the @showcased widget class must have a default constructor with no required parameters without default values OR define a `forDesignTime()` factory constructor. The reason for this is that widgets are usually created with context specific constructor parameters. When rendering the preview of the widget, we don’t necessarily know the right values for these parameters. So, we let the user to provide them for us via this specially named constructor.

## 0.4.1
- Remove unused import.

## 0.4.0
- Load custom fonts (defined in project pubspec.yaml) aside from Roboto before showcasing.

## 0.3.0
- Make showcased widgets display fonts.

Following https://github.com/flutter/flutter/issues/17700, it's now possible to display fonts on golden files, so it is on showcase as well.

Showcase will use the Roboto font by trying to locate it on the filesystem package cache folder, or downloading it from the internet.

## 0.2.0
- Make generator create a `.showcased_test` file instead of `_test.showcased` https://github.com/Igor1201/showcase/pull/7.

## 0.1.0
- Beta. Use with caution, lots of missing features.
