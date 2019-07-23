<script>
export default {
  props: {},
  computed() {
    return {
      isComplete() {
        return false;
      },
    };
  },
};
</script>
<template>
  <form class="add-stage-form">
    <div>
      <h2>New stage</h2>
    </div>
    <div>
      <label class="form-section-title label-bold" for="add-stage-name">Name</label>
      <input
        class="form-control"
        type="text"
        value=""
        name="add-stage-name"
        :placeholder="__('Enter a name for the stage')"
      />
    </div>
    <!-- 
        TODO: Double check if we need this 
        - Does this filter the list of start / stop events.... 🤔
      -->
    <div>
      <label class="form-section-title label-bold" for="add-stage-object-type">Object type</label>
      <select class="form-control" name="add-stage-object-type">
        <option>Select one or more objects</option>
      </select>
      <span>{{ __('Choose which object types will trigger this stage') }} </span>
    </div>
    <div>
      <label class="form-section-title label-bold" for="add-stage-start-event">Start event</label>
      <select class="form-control" name="add-stage-start-event">
        <option>Select start event</option>
      </select>
    </div>
    <div>
      <label class="form-section-title label-bold" for="add-stage-stop-event">Stop event</label>
      <select class="form-control" name="add-stage-stop-event">
        <option>Select stop event</option>
      </select>
      <span>{{ __('Please select a start event first') }}</span>
    </div>
    <div class="add-stage-form-actions clearfix">
      <!-- 
          TODO: what does the cancel button do?
          - Just hide the form?
          - clear entered data?
        -->
      <button class="btn btn-cancel add-stage-cancel" type="button" @click="cancelHandler()">
        {{ __('Cancel') }}
      </button>
      <button
        :disabled="!isComplete"
        type="button"
        class="js-add-stage btn btn-success"
        @click="handleSave()"
      >
        {{ __('Add stage') }}
      </button>
    </div>
  </form>
</template>
