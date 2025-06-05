.PHONY: build clean watch

# Build once
build:
	flutter pub run build_runner build --delete-conflicting-outputs

# Clean generated files
clean:
	flutter pub run build_runner clean

# Watch for changes and rebuild
watch:
	flutter pub run build_runner watch --delete-conflicting-outputs

# Build with verbose output
build-verbose:
	flutter pub run build_runner build --delete-conflicting-outputs --verbose

# Generate all at once (clean and build)
generate:
	flutter pub run build_runner clean
	flutter pub run build_runner build --delete-conflicting-outputs