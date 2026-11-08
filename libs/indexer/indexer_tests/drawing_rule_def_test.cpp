#include "testing/testing.hpp"

#include "indexer/drawing_rule_def.hpp"

namespace drawing_rule_def_test
{
using namespace drule;

// Drules priorities of BG-by-size areas (priorities_1_BG-by-size.prio.txt + kBasePriorityBgBySize).
int constexpr kCoastline = -1990, kIslet = -1980, kForest = -1940, kStadium = -1750;

UNIT_TEST(CalcAreaBySizeDepth_SimilarSizesFollowPriorities)
{
  // E.g. a forest multipolygon outer sharing a ring with an islet.
  m2::RectD const islet(0, 0, 1, 1);
  TEST_GREATER(CalcAreaBySizeDepth(islet, kForest), CalcAreaBySizeDepth(islet, kIslet), ());

  // A higher priority area stays on top when it is a little bigger.
  TEST_GREATER(CalcAreaBySizeDepth({0, 0, 1.05, 1}, kForest), CalcAreaBySizeDepth(islet, kIslet), ());

  // But not when it is noticeably bigger.
  TEST_LESS(CalcAreaBySizeDepth({0, 0, 1.1, 1}, kForest), CalcAreaBySizeDepth(islet, kIslet), ());
  TEST_LESS(CalcAreaBySizeDepth({0, 0, 2, 2}, kStadium), CalcAreaBySizeDepth(islet, kCoastline), ());
}

UNIT_TEST(CalcAreaBySizeDepth_Range)
{
  int constexpr kMinPriority = kBasePriorityBgBySize, kMaxPriority = kBasePriorityBgTop - 1;
  for (int priority : {kMinPriority, kMaxPriority})
  {
    for (double size : {0.0, 1.0E-6, 50.0})
    {
      double const depth = CalcAreaBySizeDepth({0, 0, size, size}, priority);
      TEST_GREATER_OR_EQUAL(depth, kBaseDepthBgBySize, (priority, size));
      TEST_LESS(depth, kBaseDepthBgTop, (priority, size));
    }
  }
}
}  // namespace drawing_rule_def_test
