// Dummy source to create a static archive for header-only external dependencies (Boost subset, Eigen)
// Provides a symbol so the archive is non-empty.
extern "C" int externals_dummy_symbol = 0;
