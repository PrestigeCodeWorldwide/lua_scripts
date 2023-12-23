# WINDOW nonsense

This gets you the Name of the first Task

`${Window[TaskWnd/TASK_TaskWnd/TASK_TaskList].List[1,3]}`

This gets you the description of THE FIRST step:

`${Window[TaskWnd/TASK_TaskWnd/TASK_TaskElementWnd/TASK_TaskElementList].List[1,1]}`

This gets you description of your current step
`${Task[${Window[TaskWnd/TASK_TaskWnd/TASK_TaskList].List[1,3]}].Step}`