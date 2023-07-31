from dataclasses import dataclass
from typing import Optional
from pprint import pprint

NUM_STRIDES = 32
STRIDE_MIN = -16
STRIDE_MAX = 15

@dataclass
class Stimulus:
    value: Optional[int]
    finish: bool

class CoverageDatabase:
    stride_1_seen: list[int]
    stride_2_seen: list[list[int]]
    misc_bins: dict[str, int]

    def output_coverage(self):
        print ("****************** One Stride Bins *************")
        for i in range(STRIDE_MIN, STRIDE_MAX + 1):
            if i < 0:
                stride_offset = NUM_STRIDES + i
            else:
                stride_offset = i

            print (i, self.stride_1_seen[stride_offset])

        print ("****************** Two Stride Bins *************")

        for i in range(STRIDE_MIN, STRIDE_MAX + 1):
            if i < 0:
                stride_offset_1 = NUM_STRIDES + i
            else:
                stride_offset_1 = i

            for j in range(STRIDE_MIN, STRIDE_MAX + 1):
                if i == j:
                    # Where the two strides are the same we'll never see
                    # coverage (as this is the single stride case)
                    continue

                if j < 0:
                    stride_offset_2 = NUM_STRIDES + j
                else:
                    stride_offset_2 = j

                print (i, j, self.stride_2_seen[stride_offset_1][stride_offset_2])

        pprint(self.misc_bins)

    # Flatten all coverage bins into a single vector (python list of integers)
    def get_coverage_vector(self):
        coverage_vector = []

        # Drop the stride_2 bins where both have the same stride from the
        # coverage vector (these will never be covered as they're captured as
        # single strides).
        for i, bins in enumerate(self.stride_2_seen):
            for j, bin_val in enumerate(bins):
                if (i != j):
                    coverage_vector.append(bin_val)

        coverage_vector += self.stride_1_seen
        coverage_vector += self.misc_bins.values()

        return coverage_vector

    def get_coverage_bool_vector(self):
        return [1 if x > 0 else 0 for x in self.get_coverage_vector()]