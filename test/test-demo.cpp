#include <gtest/gtest.h>
#include "sum.hpp"
#include "subtract/subtract.hpp"

namespace
{

TEST(LibraryTests_hello, add) {
    EXPECT_EQ(13, sum(12, 1));
    EXPECT_EQ(3, subtract(10, 7));
}

} // ns <anonymous>