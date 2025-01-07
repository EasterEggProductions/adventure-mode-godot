# adventure-mode-godot

Adventure Mode is a 3D third-person template for the Godot engine that combines the basic movement and exploration mechanics, as well as the foundational combat experiences of a wide variety of games:

- **The Legend of Zelda: Breath of the Wild**
- **The Legend of Zelda: Tears of the Kingdom**
- **Dark Souls 1, 2, 3**
- Not *Bloodborne* (I hate *Bloodborne*. Just go play *Devil May Cry*.)
- **Elden Ring**

---

## Key Features
- **Movement and Exploration**:
  - Moving and jumping in 3D space with a variety of modes: walking, running, jumping, climbing, swimming, and flying.
- **Combat**:
  - Basic melee and ranged attacks determined by data, such as equipped weapons or stats.
- **Item Management**:
  - Usage of items such as potions (both consumable and reusable).
- **Multiplayer**:
  - Includes a foundational multiplayer setup.

### Excluded Features
Some systems are intentionally omitted or left as basic templates to be customized by end developers:
- Inventory management systems.
- Character building (stats and leveling up).
- Terrain generation (e.g., voxels, heightmaps).
- Advanced graphics.
- Scalable netcode solutions.

---

## Goals
- Implement basic walking and running mechanics.
- Extend to additional movement modes, such as parkour, climbing, swimming, and flying.
- Provide a functional, basic combat system.

---

## Multiplayer Information
A basic implementation of multiplayer functionality is provided using Godot's built-in systems. It is expected that developers will replace or extend this system to suit their specific needs. Examples of customizations may include:
- Matchmaking.
- Lag compensation.
- Other advanced network features.

While the default setup includes syncing data and structures such as positions, item use, animation states, and character customization, the network code is not designed as a scalable, one-size-fits-all solution.

---

## Art Assets
The included art assets aim for a late N64 aesthetic, balancing a retro vibe with practical considerations like binary file size and developer limitations. 

### Key Details:
- Assets are designed to be easily reskinned or upgraded by skilled artists.
- Additional data, such as extra animation bones (e.g., all finger joints), is included in the default models to facilitate detailed customization.

---

## Contributing
Contributions to this project are welcome and encouraged! To contribute:
1. **Fork the repository**: Create your own copy of the project.
2. **Make your changes**: Implement features, fix bugs, or improve documentation.
3. **Submit a pull request**: Provide a clear explanation of your changes, including the problem they solve or the feature they add.

### Guidelines
- Ensure your contributions align with the goals of the project.
- Follow coding standards and include documentation for any new features.
- Test your changes thoroughly before submitting.

Thanks for helping improve Adventure Mode!

---

## Licenses
- **MIT License**: Applies to the software code in this repository. See the LICENSE file for full terms.
- **CC-BY 4.0 License**: Applies to art assets, including 3D models, animations, and written materials. See the LICENSE file for full terms.

---

## Recommended Tools
To enhance your development workflow, the following tools are recommended:

- **[Visual Studio Code](https://code.visualstudio.com/)**: A lightweight and versatile code editor available on various platforms.
  - Add-on: **[Comment Anchors](https://marketplace.visualstudio.com/items?itemName=ExodiusStudios.comment-anchors)**: Helps you organize and keep track of tasks or specific sections of code while working.

- **[GodotEnv](https://github.com/chickensoft-games/GodotEnv)**: A tool for managing Godot addons efficiently. It simplifies the process of adding, updating, and organizing addons within your project. It is still young, but referencing other addons of specific versions seems like a good capability to keep the repository lean. This tool may become required to properly set up the project at some point. 

