#include <iostream>
#include <string>
#include <vector>


// just a basic prototype for pushing to github purposes
int main() {
    std::vector<std::string> restaurants = {
        "Pasta Palace",
        "Sushi Central",
        "Burger Barn",
        "Taco Tower"
    };

    std::cout << "Welcome to the Restaurant Finder!" << std::endl;
    std::cout << "Here are some restaurants you might like:" << std::endl;

    for (const auto& restaurant : restaurants) {
        std::cout << "- " << restaurant << std::endl;
    }

    return 0;
}
