using GUITestRunner
using TestRunner
using FactCheck
using Tk

not_throw(_) = true

facts("Helper functions tests") do
  context("Getting test buttons icons") do
    @fact GUITestRunner.get_image(TestRunner.test_success) |> typeof --> Tk.Tk_Image "Returns image"
    @fact_throws GUITestRunner.get_image("wrong") "Throws exception for unspecified test result."
  end
  context("Colors for collections and context") do
    factCollectionNode = TestRunner.FactsCollectionNode(0,"Collection", Vector{TestRunner.TestStructureNode}())
    contextNode = TestRunner.ContextNode(0,"Context", Vector{TestRunner.TestStructureNode}())
    factNode = TestRunner.FactNode(0,"Node")
    @fact GUITestRunner.get_color(factCollectionNode) --> "#C0C0C0" "Correct color for collection"
    @fact GUITestRunner.get_color(contextNode) --> "#FFCC99" "Correct color for contect"
    @fact GUITestRunner.get_color(factNode) --> "white smoke"
  end
end

facts("GUI") do
  context("Main window") do
    window = start_test_runner()
    @fact exists(window) --> true "Window exists"
    @fact window.children[1].children |> length --> 6 "Frame children count"
    @fact window[:width] --> "350" "Window width"
    @fact window[:height] --> "600" "Window height"
    destroy(window)
  end
  context("New window") do
    window = GUITestRunner.create_new_window("Test window", 100,200)
    @fact window[:width] --> "100" "Window width"
    @fact window[:height] --> "200" "Window height"
    @fact Tk.get_value((window.children[1].children[1])) --> "Test window" "Window name"
    destroy(window)
  end
  context("Test details window") do
    window = start_test_runner()
    frame = window.children[1]
    GUITestRunner.display_test_details!(frame, "Test Details")
    @fact Tk.get_value(GUITestRunner.get_frame_for_test_details(frame).children[2].children[1]) --> "Test Details" "Correct text displayed"
    GUITestRunner.clear_current_tests!(frame)
    @fact GUITestRunner.get_frame_for_test_details(frame).children |> length --> 0 "Test details cleared"
    destroy(window)
  end
end

facts("Children operations") do
  window = start_test_runner()
  frame = window.children[1]
  frame_for_tests = GUITestRunner.get_frame_for_tests(frame)
  test1 = Label(frame_for_tests)
  test2 = Label(frame_for_tests)
  test3 = Label(frame_for_tests)
  map(t -> pack(t), (test1, test2, test3))
  @fact frame_for_tests.children |> length --> 3 "Tests labels count"
  GUITestRunner.clear_current_tests!(frame)
  @fact frame_for_tests.children |> length --> 0 "Tests removed"
  destroy(window)
end

facts("Happy path") do
  window = start_test_runner()
  frame = window.children[1]
  file_name_input = frame.children[1]
  set_value(file_name_input, "./sampleTests.jl")
  @fact GUITestRunner.load_tests_button_callback!(frame) --> not_throw "Loading tests does not throw"
  @fact GUITestRunner.run_tests_button_callback!(frame) --> not_throw "Running tests does not throw"
  destroy(window)
end
