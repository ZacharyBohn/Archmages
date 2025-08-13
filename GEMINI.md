# Gemini Development Guidelines

- Use object oriented programming to design any software that is requested of you.
- Design abstract classes, just defining their interfaces, even when you don't have it. This will allow Gemini to read very few classes and understand them without having to read the implementations. You don't have to do this with every class, but prefer to do so if classes have anything other than trivial implementations.
- Create a app_outline.json file that will have a hierarchy of structure that relates to any app you write. This will allow you to quickly and easily think through the structure.
- Any non-trivial flows in this app should also be written as a step-by-step process in app_flows.md
- Write any app-level design decisions in designs.md to keep track of the why behind decisions, or any goals for the software.