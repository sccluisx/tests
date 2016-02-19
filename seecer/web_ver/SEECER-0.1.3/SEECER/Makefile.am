AM_LDFLAGS = -lgomp -ggdb3
AM_CPPFLAGS = -Wno-deprecated -Wall $(SEQAN_CFLAGS) -fopenmp -ggdb3
AM_CXXFLAGS = -O0 -pg -gstabs -ggdb3

bin_PROGRAMS = bin/seecer \
	bin/random_sub_N \
	bin/replace_ids

bin_seecer_SOURCES = src/seecer_main.cpp \
	src/common.cpp \
	src/hashmap_read_finder.cpp \
	src/hmm_cluster.cpp \
	src/smart_hashmap_read_finder.cpp \
	src/stats_keeper.cpp

bin_random_sub_N_SOURCES = pipeline/random_sub_N.cc
bin_replace_ids_SOURCES = pipeline/replace_ids.cc
