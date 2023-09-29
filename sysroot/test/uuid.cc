#include <uuid/uuid.h>
#include <iostream>

int main() {
    uuid_t uuid{};
    uuid_generate_random(uuid);
    std::cout << "uuid: " << uuid << std::endl;
}
