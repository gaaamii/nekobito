import { screen, waitFor } from '@testing-library/dom'
import '@testing-library/jest-dom'
import userEvent from '@testing-library/user-event';

test('Show textarea', async () => {
  const textarea = await screen.findByRole('textbox')
  expect(textarea).toHaveAttribute("placeholder", "# Markdown text here")
})

test('Switch layout', async () => {
  const openSidebarButton = await screen.findByRole("button", { name: "Open sidebar" })
  userEvent.click(openSidebarButton)

  // change to split mode
  const splitRadioInput = await screen.findByLabelText("split")
  userEvent.click(splitRadioInput)
  await waitFor(() => {
    expect(splitRadioInput).toBeChecked()
  })

  // change to edit mode
  const editRadioInput = screen.getByLabelText("edit")
  userEvent.click(editRadioInput)
  await waitFor(() => {
    expect(editRadioInput).toBeChecked()
  })

  // change to view mode
  const viewRadioInput = screen.getByLabelText("view")
  userEvent.click(viewRadioInput)
  await waitFor(() => {
    expect(viewRadioInput).toBeChecked()
  })
})

test('Change theme', async () => {
  const openSidebarButton = await screen.findByRole("button", { name: "Open sidebar" })
  userEvent.click(openSidebarButton)

  // change to dark theme
  const darkRadioInput = await screen.findByLabelText("dark")
  userEvent.click(darkRadioInput)
  await waitFor(() => {
    expect(darkRadioInput).toBeChecked()
  })

  // change to white theme
  const whiteRadioInput = screen.getByLabelText("white")
  userEvent.click(whiteRadioInput)
  await waitFor(() => {
    expect(whiteRadioInput).toBeChecked()
  })
})
