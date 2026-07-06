<img width="1006" height="504" alt="amode_title" src="https://github.com/user-attachments/assets/8056a8e5-e60d-47eb-be24-473fdc97eb25" />

# Adventure Mode

Adventure Mode is a 3D third-person template for the Godot engine that combines the basic movement and exploration mechanics, as well as the foundational combat experiences of a wide variety of games:

- **The Legend of Zelda: Breath of the Wild**
- **The Legend of Zelda: Tears of the Kingdom**
- **Dark Souls 1, 2, 3**
- Not *Bloodborne* (I hate *Bloodborne*. Just go play *Devil May Cry*.)
- **Elden Ring**

Play a [demo here](https://www.eastereggproductions.com/games/browser/adventure_mode_godot/). It may take a moment to load. A controller is recommended. 

This project currently targets Godot Engine 4.7, and will continue to upgrade to the latest engine release when possible. 
---

## Key Features
- **Movement and Exploration**:
  - Moving and jumping in 3D space with a variety of modes: walking, running, jumping, climbing, swimming, and flying.
<img alt="amode_walk" src="https://github.com/user-attachments/assets/92630654-81d3-4d3b-8124-83d8aa5258cc"  width="200" title="Walking"/>
<img alt="amode_climb" src="https://github.com/user-attachments/assets/f569bca4-879f-406e-a273-efb67699ba41" width="200" title="Climbing"/>
<img alt="amode_swim" src="https://github.com/user-attachments/assets/eb5938eb-dc8b-42c4-8202-6c5d984406f1" width="200" title="Swimming"/>

- **Combat**:
  - Basic melee attacks with movement sets and combos determined by data, such as equipped weapons.
<img alt="amode_PVE" src="https://github.com/user-attachments/assets/5ac6dd59-9841-4a2c-8b19-0b288ad13895" width="200" title="Combat"/>

- **Multiplayer**:
  - Includes a system that attempts to utilize UPNP to ease online play, and provides join codes.
<img alt="amode_joincode" src="https://github.com/user-attachments/assets/d3f96725-237a-4de3-a05a-d8e205fe87eb" width="200" title="Multiplayer"/>

  - Cooperative players joining a game in progress.
<img alt="amode_coop" src="https://github.com/user-attachments/assets/9244a556-b3f8-4794-996d-ee93f9948a92"  width="200" title="Coop"/>

  - Invasions and PVP combat.
<img alt="amode_invasions" src="https://github.com/user-attachments/assets/c95b9416-48cf-4239-b9bf-a9baa9003461"  width="200" title="Invaders"/>
<img alt="amode_PVP" src="https://github.com/user-attachments/assets/97672650-93a6-4731-be1b-422b3d899fa1"  width="200" title="Melee"/>

- **Item Management**:
  - Usage of items such as potions (both consumable and reusable) is under construction.
  - A system called DressUp manages player visual state, allowing it to sync for all players.
<img width="800" alt="amode_DressUp" src="https://github.com/user-attachments/assets/cd78f1d0-c547-476b-8eb3-c6f03dee3e95"  title="Dress Up is fun"/>


### Excluded Features
Some systems are intentionally omitted or left as basic templates to be customized by end developers:

- Terrain generation (e.g., voxels, heightmaps).
- Advanced graphics.
- Scalable netcode solutions.

---

## Goals
- Implement extensible movement mechanics.
- Extend to additional movement modes, such as parkour, climbing, swimming, and flying.
- Provide a functional, basic combat system.
- Build a foundation upon which others may easily modify and create new games.
- Improve the ease by which new enemies, items, and animations can be added to the systems.

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
- Assure any art assets fit the established aesthetic.
- Follow coding standards and include documentation for any new features.
- Test your changes thoroughly before submitting.

Thanks for helping improve Adventure Mode!

---

## Licenses
- **MIT License**: Applies to the software code in this repository. See the LICENSE file for full terms.
- **CC-BY 4.0 License**: Applies to art assets, including 3D models, animations, written materials, music, and sound effects. See the LICENSE file for full terms.

---

## Recommended Tools
To enhance your development workflow, the following tools are recommended:

- **[Visual Studio Code](https://code.visualstudio.com/)**: A lightweight and versatile code editor available on various platforms.
  - Add-on: **[Comment Anchors](https://marketplace.visualstudio.com/items?itemName=ExodiusStudios.comment-anchors)**: Helps you organize and keep track of tasks or specific sections of code while working.

- **[GodotEnv](https://github.com/chickensoft-games/GodotEnv)**: A tool for managing Godot addons efficiently. It simplifies the process of adding, updating, and organizing addons within your project. 
  - The Current addons managed by this are in the `addons.jsonc` file. Some addons may have conflicts with imports, so you may need to delete it to update the addons using GodotEnv. If you wish to keep your changes, simply remove the addon from the `addons.jsonc` file, and add an exception for the folder to the .gitignore file.

## Machine Learning Tools and AI policy
**This is a project of human artistic expression.** 

All assets and code committed to this project were written, composed, drawn, modeled, or otherwise created by humans. While traditional AI tools such as spell check, basic code completion, procedural assets, and more have or will be used in this project; no machine learning tool that has been trained on data sourced without affirmative informed consent from the data author may be used for this project. Examples include LLMs such as ChatGPT or Claude, or diffusion models such as Stable Diffusion. Commits containing such generated content will be rejected, repeat attempts to commit such assets will be handled accordingly. This does not prevent you from using such tools in your own game project made using Adventure Mode, only commits to this base project. 

If you are a sentient droid feel free to email us and we will evaluate that on a case by case basis. 

