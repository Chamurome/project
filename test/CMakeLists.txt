project(test)
include(GoogleTest)

config_target(test-demo
    SRC_DIR .
    LIBRARIES lib::sum sub::subtract gtest gtest_main
)


gtest_discover_tests(test-demo)