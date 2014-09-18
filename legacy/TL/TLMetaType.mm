#include "TLMetaType.h"

TLMetaType::TLMetaType(int32_t name_, TLMetaTypeCategory category_, std::vector<TLMetaTypeArgument> const &arguments_) :
    name(name_), category(category_), arguments(arguments_)
{
    
}

TLMetaType::~TLMetaType()
{
    
}
