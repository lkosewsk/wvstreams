LIBWVBASE=$(WVSTREAMS_LIB)/libwvbase.so $(LIBXPLC)
LIBWVUTILS=$(WVSTREAMS_LIB)/libwvutils.so $(LIBWVBASE)
LIBWVSTREAMS=$(WVSTREAMS_LIB)/libwvstreams.so $(LIBWVUTILS)
LIBWVOGG=$(WVSTREAMS_LIB)/libwvoggvorbis.so $(LIBWVSTREAMS)
LIBUNICONF=$(WVSTREAMS_LIB)/libuniconf.so $(LIBWVSTREAMS)
LIBWVDBUS=$(WVSTREAMS_LIB)/libwvdbus.so $(LIBWVSTREAMS)
LIBWVQT=$(WVSTREAMS_LIB)/libwvqt.so $(LIBWVSTREAMS)
LIBWVTEST=$(WVSTREAMS_LIB)/libwvtest.a $(LIBWVUTILS)
LIBWVSTATIC=$(WVSTREAMS_LIB)/libwvstatic.a

#
# Initial C compilation flags
#
INCFLAGS=$(addprefix -I,$(WVSTREAMS_INC) $(XPATH))

CPPFLAGS += $(CPPOPTS)
CFLAGS += $(COPTS)
CXXFLAGS += $(CXXOPTS)
LDFLAGS += $(LDOPTS) -L$(WVSTREAMS_LIB)

# Default compiler we use for linking
WVLINK_CC = $(CXX)

ifneq ("$(enable_optimization)", "no")
  CXXFLAGS+=-O2
  CFLAGS+=-O2
endif

ifneq ("$(enable_warnings)", "no")
  CXXFLAGS+=-Wall -Woverloaded-virtual
  CFLAGS+=-Wall
endif

DEBUG:=$(filter-out no 0,$(enable_debug))
ifdef DEBUG
  CPPFLAGS += -ggdb -DDEBUG=1 $(patsubst %,-DDEBUG_%,$(DEBUG))
  LDFLAGS += -ggdb
else
  CPPFLAGS += -DDEBUG=0
  LDFLAGS += 
endif

define wvlink_ar
	$(LINK_MSG)set -e; rm -f $1 $(patsubst %.a,%.libs,$1); \
	echo $2 >$(patsubst %.a,%.libs,$1); \
	$(AR) q $1 $(filter %.o,$2); \
	for d in "" $(filter %.libs,$2); do \
	    if [ "$$d" != "" ]; then \
			cd $$(dirname "$$d"); \
			$(AR) q $(shell pwd)/$1 $$(cat $$(basename $$d)); \
			cd $(shell pwd); \
		fi; \
	done; \
	$(AR) s $1
endef

CC: FORCE
	@CC="$(CC)" CFLAGS="$(CFLAGS)" CPPFLAGS="$(CPPFLAGS)" \
	  $(WVSTREAMS)/gen-cc CC c

CXX: FORCE
	@CC="$(CXX)" CFLAGS="$(CXXFLAGS)" CPPFLAGS="$(CPPFLAGS)" \
	  $(WVSTREAMS)/gen-cc CXX cc

wvlink=$(LINK_MSG)$(CC) $(LDFLAGS) $($1-LDFLAGS) -o $1 $(filter %.o %.a %.so, $2) $($1-LIBS) $(LIBS) $(XX_LIBS) $(LDLIBS)
