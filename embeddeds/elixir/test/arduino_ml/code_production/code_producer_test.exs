defmodule ArduinoML.CodeProducerTest do
  use ExUnit.Case
  doctest ArduinoML.CodeProducer

  import ArduinoML

  test "Should translate well a minimalistic application" do
    application "Testing!"

    sensor button: 1
    actuator led: 2
    
    state :released, on_entry: :led ~> :low
    state :pressed, on_entry: :led ~> :high

    transition from: :released, to: :pressed, when: is_high?(:button)
    transition from: :pressed, to: :released, when: is_low?(:button)

    expected = """
    // generated by ArduinoML #Elixir.

    // Bricks <~> Pins.
    int BUTTON = 1;
    int LED = 2;

    // Setup the inputs and outputs.
    void setup() {
      pinMode(BUTTON, INPUT);

      pinMode(LED, OUTPUT);
    }

    // Static setup code.
    int state = LOW;
    int prev = HIGH;
    long time = 0;
    long debounce = 200;

    // States declarations.
    void state_pressed() {
      digitalWrite(LED, HIGH);

      boolean guard = millis() - time > debounce;

      if (digitalRead(BUTTON) == LOW && guard) {
        time = millis();
        state_released();
      } else {
        state_pressed();
      }
    }

    void state_released() {
      digitalWrite(LED, LOW);

      boolean guard = millis() - time > debounce;

      if (digitalRead(BUTTON) == HIGH && guard) {
        time = millis();
        state_pressed();
      } else {
        state_released();
      }
    }

    // This function specifies the first state.
    void loop() {
      state_released();
    }
    """

    assert ArduinoML.CodeProducer.to_code(application!()) == expected
  end
  
end
